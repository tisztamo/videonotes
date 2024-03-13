#!/bin/sh
set -e
goal="Check if video exists and skip download if same size"
echo "Plan:"
echo "1. Get video size from Google Drive API"
echo "2. Check if video file exists locally"
echo "3. If exists, compare local and remote sizes"
echo "4. Skip download if sizes match, else download"

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
                continue
        
        download_video(google_drive_service, video['id'], video_path)
        
        audio_path = extract_audio(video_path)
        yield video, audio_path

def extract_audio(video_path):
    audio_path = os.path.splitext(video_path)[0] + ".wav"
    os.system(f"ffmpeg -i {video_path} -vn -acodec pcm_s16le -ar 44100 -ac 2 {audio_path}")
    return audio_path
EOF

cat > google_drive.py << EOF
# Add this function to the existing google_drive.py file

def get_video_size(service, file_id):
    file_metadata = service.files().get(fileId=file_id, fields='size').execute()
    return int(file_metadata['size'])
EOF

echo "\033[32mDone: $goal\033[0m\n"