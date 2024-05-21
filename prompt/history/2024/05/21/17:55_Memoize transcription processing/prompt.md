You are AI Junior, you code like Donald Knuth.

# Task

Implement the following feature!

- Create a plan!
- Create new files when needed!

Requirements:

Memoize transcription processing


## Project Specifics

Prefer short files! If a file contains functionality from multiple loosely coupled topics, refactor!

Write concise, self-documenting and idiomatic Python code!

# Output Format

Encode and enclose your results as ./change.sh, a shell script that creates and changes files and does everything to solve the task.
Avoid using sed. Always heredoc full files.

OS: Debian


Installed tools: npm, jq


Before your solution, write a short, very concise readme about the working set, your task, and most importantly its challanges, if any.


EXAMPLE START
```sh
#!/bin/sh
set -e
goal=[Task description, max 9 words]
echo "Plan:"
echo "1. [...]"

# Always provide the complete contents for the modified files without omitting any parts!
cat > x.js << EOF
  let i = 1
  console.log(\`i: \${i}\`)
EOF
echo "\033[32mDone: $goal\033[0m\n"
```
EXAMPLE END

Before starting, check if you need more files or info to solve the task.

If the task is not clear:

EXAMPLE START
I need more information to solve the task. [Description of the missing info]
EXAMPLE END

Do not edit files not provided in the working set!
If you need more files:

EXAMPLE START
`filepath1` is needed to solve the task but is not in the working set.
EXAMPLE END

# Working set

videonotes/tools/memoizer.py:
```
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
            
            # Create table if it doesn't exist
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS memoizer (
                    id TEXT PRIMARY KEY,
                    result BLOB
                )
            ''')
            
            # Create a unique key based on function name and arguments
            key = f"{func.__name__}:{args}:{kwargs}"
            key_hash = hashlib.sha256(key.encode()).hexdigest()
            
            # Check if result is already cached
            cursor.execute('SELECT result FROM memoizer WHERE id = ?', (key_hash,))
            row = cursor.fetchone()
            if row:
                result = pickle.loads(row[0])
                conn.close()
                return result
            
            # Call the actual function and store the result
            result = func(*args, **kwargs)
            cursor.execute('INSERT INTO memoizer (id, result) VALUES (?, ?)', (key_hash, pickle.dumps(result)))
            conn.commit()
            conn.close()
            return result
        return wrapper
    return decorator

```
videonotes/transcription_processing.py:
```
import os
from .llm.openai.openai_transcribe import transcribe_audio

def process_transcriptions(videos):
    transcription_filenames = []
    for video, video_path, audio_path in videos:
        print(f"Transcription starting for {video['name']}")
        transcript = transcribe_audio(audio_path)
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

```
main.py:
```
from videonotes.google_drive import authenticate_google_drive
from videonotes.video_processing import download_media, extract_audio
from videonotes.transcription_processing import process_transcriptions  
from videonotes.summary_processing import summarize_transcription
from videonotes.task_extraction import extract_tasks_from_summary
from videonotes.database import create_database, mark_file_processed

def main():
    # Create database if it doesn't exist
    create_database()
    
    # Google Drive setup
    google_drive_service = authenticate_google_drive()
    folder_id = '1ph59F7sO3liciGwzevdmh-06yB0ThcAe'
    
    # Download new videos
    videos = []
    for media_file, local_path in download_media(google_drive_service, folder_id):
        audio_path = extract_audio(local_path)
        videos.append((media_file, local_path, audio_path))
    
    # Process transcriptions for downloaded videos  
    transcription_filenames = process_transcriptions(videos)
    summary_filenames = list(map(summarize_transcription, transcription_filenames))
    if len(summary_filenames) > 0:
        print(f"Created {len(summary_filenames)} summary files:")
        print('\n'.join(summary_filenames))
    
    # Extract tasks
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

```