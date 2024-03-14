#!/bin/sh
set -e
goal="Summarize transcriptions with OpenAI"
echo "Plan:"
echo "1. Integrate OpenAI summarization in transcription processing."
echo "2. Create summary_processing.py for handling summaries."
echo "3. Update main.py to include summarization."
echo "4. Ensure ./summaries/ directory exists."

# Update transcription_processing.py to include summarization call
cat > transcription_processing.py << EOF
import os
from openai_transcribe import transcribe_audio
from summary_processing import summarize_transcription

def process_transcriptions(videos):
    transcription_filenames = []
    for video, audio_path in videos:
        transcript = transcribe_audio(audio_path)
        print(f"Transcription completed for {video['name']}")
        transcription_filename = write_transcription_to_file(video, transcript.text)
        transcription_filenames.append(transcription_filename)
        summarize_transcription(transcription_filename)
    return transcription_filenames

def write_transcription_to_file(video, transcript):
    os.makedirs('transcriptions', exist_ok=True)
    filename = f"transcriptions/{os.path.splitext(video['name'])[0]}.txt"
    with open(filename, 'w') as f:
        f.write(transcript)
    print(f"Transcription written to {filename}")
    return filename
EOF

# Create summary_processing.py to handle summary generation and storage
cat > summary_processing.py << EOF
import os
from openai import OpenAI

client = OpenAI()

def summarize_transcription(transcription_filename):
    with open(transcription_filename, 'r') as f:
        transcript = f.read()
    
    summary = client.completions.create(
          model="text-davinci-003", 
          prompt=f"Summarize this detailed transcript: {transcript}",
          max_tokens=150
    )

    os.makedirs('./summaries/', exist_ok=True)
    summary_filename = f"./summaries/{os.path.basename(transcription_filename)}"
    with open(summary_filename, 'w') as f:
        f.write(summary.choices[0].text)
    print(f"Summary written to {summary_filename}")
EOF

# Update main.py to reflect new summarization step
cat > main.py << EOF
from google_drive import authenticate_google_drive
from video_processing import download_videos, extract_audio
from transcription_processing import process_transcriptions

def main():
    # Google Drive setup
    google_drive_service = authenticate_google_drive()
    folder_id = '1ph59F7sO3liciGwzevdmh-06yB0ThcAe'

    # Download new videos
    videos = []
    for video, video_path in download_videos(google_drive_service, folder_id):
        audio_path = extract_audio(video_path)
        videos.append((video, video_path, audio_path))

    # Process transcriptions for downloaded videos
    transcription_filenames = process_transcriptions(videos)

if __name__ == '__main__':
    main()
EOF

echo "\033[32mDone: $goal\033[0m\n"
