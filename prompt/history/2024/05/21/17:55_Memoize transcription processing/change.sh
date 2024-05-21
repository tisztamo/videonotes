#!/bin/sh
set -e
goal="Memoize transcription processing"
echo "Plan:"
echo "1. Refactor memoizer.py."
echo "2. Integrate memoization into transcription processing."
echo "3. Update transcription_processing.py."
echo "4. Update main.py."

# Refactor memoizer.py
cat > videonotes/tools/memoizer.py << 'EOF'
import sqlite3
import os
import hashlib
import pickle

def get_db_path(model_name):
    db_filename = f"{model_name}.db"
    db_path = os.path.join(os.path.dirname(__file__), db_filename)
    return db_path

def memoize(model_name):
    def decorator(func):
        def wrapper(*args, **kwargs):
            db_path = get_db_path(model_name)
            conn = sqlite3.connect(db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS memoizer (
                    id TEXT PRIMARY KEY,
                    result BLOB
                )
            ''')
            
            key = f"{func.__name__}:{args}:{kwargs}"
            key_hash = hashlib.sha256(key.encode()).hexdigest()
            
            cursor.execute('SELECT result FROM memoizer WHERE id = ?', (key_hash,))
            row = cursor.fetchone()
            if row:
                result = pickle.loads(row[0])
                conn.close()
                return result
            
            result = func(*args, **kwargs)
            cursor.execute('INSERT INTO memoizer (id, result) VALUES (?, ?)', (key_hash, pickle.dumps(result)))
            conn.commit()
            conn.close()
            return result
        return wrapper
    return decorator
EOF

# Integrate memoization into transcription processing
cat > videonotes/transcription_processing.py << 'EOF'
import os
from .llm.openai.openai_transcribe import transcribe_audio
from .tools.memoizer import memoize

@memoize("transcription")
def memoized_transcribe_audio(audio_path):
    return transcribe_audio(audio_path)

def process_transcriptions(videos):
    transcription_filenames = []
    for video, video_path, audio_path in videos:
        print(f"Transcription starting for {video['name']}")
        transcript = memoized_transcribe_audio(audio_path)
        transcription_filename = write_transcription_to_file(video, transcript.text)
        transcription_filenames.append(transcription_filename)
    return transcription_filenames

def write_transcription_to_file(video, transcript):
    os.makedirs('transcriptions', exist_ok=True)
    filename = f"transcriptions/{os.path.splitext(video['name'])[0]}.txt"
    with open(filename, 'w') as f:
        f.write(transcript)
    print(f"Transcription written to {filename}")
    return filename
EOF

# Update main.py to use the updated transcription process
cat > main.py << 'EOF'
from videonotes.google_drive import authenticate_google_drive
from videonotes.video_processing import download_media, extract_audio
from videonotes.transcription_processing import process_transcriptions  
from videonotes.summary_processing import summarize_transcription
from videonotes.task_extraction import extract_tasks_from_summary
from videonotes.database import create_database, mark_file_processed

def main():
    create_database()
    
    google_drive_service = authenticate_google_drive()
    folder_id = '1ph59F7sO3liciGwzevdmh-06yB0ThcAe'
    
    videos = []
    for media_file, local_path in download_media(google_drive_service, folder_id):
        audio_path = extract_audio(local_path)
        videos.append((media_file, local_path, audio_path))
    
    transcription_filenames = process_transcriptions(videos)
    summary_filenames = list(map(summarize_transcription, transcription_filenames))
    if len(summary_filenames) > 0:
        print(f"Created {len(summary_filenames)} summary files:")
        print('\n'.join(summary_filenames))
    
    all_task_filenames = []
    for summary_filename in summary_filenames:
        task_filenames = extract_tasks_from_summary(summary_filename)
        all_task_filenames.extend(task_filenames)
    
    if len(all_task_filenames) > 0:
        print(f"Created {len(all_task_filenames)} task files:")
        print('\n'.join(all_task_filenames))

    for media_file, local_path, audio_path in videos:
        file_metadata = google_drive_service.files().get(fileId=media_file['id'], fields='name,createdTime,modifiedTime,size').execute()
        mark_file_processed(media_file['id'], file_metadata['name'], file_metadata['createdTime'], 
                    file_metadata['modifiedTime'], int(file_metadata['size']))

if __name__ == '__main__':
    main()
EOF

echo "\033[32mDone: $goal\033[0m\n"
