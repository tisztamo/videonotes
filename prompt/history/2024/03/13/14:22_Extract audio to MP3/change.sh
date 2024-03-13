#!/bin/sh

set -e

goal="Extract audio to MP3"

echo "Task: Extract audio from video and compress to MP3 format."

echo "Challenges: Ensuring efficient compression while maintaining audio quality. Integration with existing video processing workflow."

echo "Plan:"
echo "1. Modify extract_audio function to output MP3."
echo "2. Ensure ffmpeg is installed and available."
echo "3. Test the process with a sample video."

# Modify video_processing.py
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
    audio_path = os.path.splitext(video_path)[0] + ".mp3"
    if not os.path.exists(audio_path):
        os.system(f"ffmpeg -i {video_path} -vn -ar 44100 -ac 2 -ab 192k -f mp3 {audio_path}")
    return audio_path
EOF

echo "\033[32mDone: $goal\033[0m\n"
