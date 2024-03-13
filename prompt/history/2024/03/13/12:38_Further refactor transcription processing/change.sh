#!/bin/sh
set -e
goal="Further refactor transcription processing"
echo "Plan:"
echo "1. Rename process_videos to download_videos in video_processing.py"
echo "2. Move transcription loop to transcription_processing.py"
echo "3. Create transcriptions directory from Python before writing files"
echo "4. Update main.py to reflect changes"

cat > video_processing.py << EOF
from google_drive import authenticate_google_drive, find_new_videos, download_video

def download_videos(google_drive_service, folder_id):
    new_videos = find_new_videos(google_drive_service, folder_id)
    for video in new_videos:
        print(f"Processing video: {video['name']}")
        video_path = f"./downloads/{video['name']}"
        download_video(google_drive_service, video['id'], video_path)
        yield video, video_path
EOF

cat > transcription_processing.py << EOF
import os
from assemblyai_transcribe import transcribe_video, check_transcription_status
import time

def process_transcriptions(videos):
    for video, video_path in videos:
        transcript_id = transcribe_video(video_path)
        print(f"Transcription initiated for {video['name']}. Transcript ID: {transcript_id}")
        
        while True:
            status_response = check_transcription_status(transcript_id)
            if status_response['status'] == 'completed':
                print(f"Transcription completed for {video['name']}")
                write_transcription_to_file(video, status_response['text'])
                break
            elif status_response['status'] == 'failed':
                print(f"Transcription failed for {video['name']}")
                break
            else:
                print(f"Transcription in progress for {video['name']}...")
                time.sleep(10)

def write_transcription_to_file(video, transcript):
    os.makedirs('transcriptions', exist_ok=True)
    filename = f"transcriptions/{os.path.splitext(video['name'])[0]}.txt"
    with open(filename, 'w') as f:
        f.write(transcript)
    print(f"Transcription written to {filename}")
EOF

cat > main.py << EOF
from google_drive import authenticate_google_drive
from video_processing import download_videos
from transcription_processing import process_transcriptions

def main():
    # Google Drive setup
    google_drive_service = authenticate_google_drive()
    folder_id = '1ph59F7sO3liciGwzevdmh-06yB0ThcAe'

    # Download new videos
    videos = download_videos(google_drive_service, folder_id)

    # Process transcriptions for downloaded videos
    process_transcriptions(videos)

if __name__ == '__main__':
    main()
EOF

echo "\033[32mDone: $goal\033[0m\n"