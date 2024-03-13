#!/bin/sh
set -e
goal="Skip audio extraction for existing files"
echo "Plan:"
echo "1. Refactor video_processing.py to separate video downloading and audio extraction"
echo "2. Check if audio file exists before extracting audio"
echo "3. Update main.py to pass video paths to process_transcriptions function"

cat > video_processing.py << EOF
import os
from google_drive import authenticate_google_drive, find_new_videos, download_video, get_video_size

def download_videos(google_drive_service, folder_id):
    new_videos = find_new_videos(google_drive_service, folder_id)
    for video in new_videos:
        print(f"Processing video: {video['name']}")
        video_path = f"./downloads/{video['name']}"
        
        # Get remote video size
        remote_size = get_video_size(google_drive_service, video['id'])
        
        # Check if local video exists and compare sizes
        if os.path.exists(video_path):
            local_size = os.path.getsize(video_path)
            if local_size == remote_size:
                print(f"Skipping {video['name']}, already downloaded with same size")
                yield video, video_path
                continue
        
        download_video(google_drive_service, video['id'], video_path)
        yield video, video_path

def extract_audio(video_path):
    audio_path = os.path.splitext(video_path)[0] + ".wav"
    if not os.path.exists(audio_path):
        os.system(f"ffmpeg -i {video_path} -vn -acodec pcm_s16le -ar 44100 -ac 2 {audio_path}")
    return audio_path
EOF

cat > main.py << EOF
from google_drive import authenticate_google_drive
from video_processing import download_videos, extract_audio
from transcription_processing import process_transcriptions

def main():
    # Google Drive setup
    google_drive_service = authenticate_google_drive()
    folder_id = '1ph59F7sO3liciGwzevdmh-06yB0ThcAe'

    # Download new videos
    video_paths = []
    for video, video_path in download_videos(google_drive_service, folder_id):
        audio_path = extract_audio(video_path)
        video_paths.append((video, audio_path))

    # Process transcriptions for downloaded videos
    process_transcriptions(video_paths)

if __name__ == '__main__':
    main()
EOF

echo "\033[32mDone: $goal\033[0m\n"