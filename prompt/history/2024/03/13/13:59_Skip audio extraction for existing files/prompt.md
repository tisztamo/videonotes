You are AI Junior, you code like Donald Knuth.

# Task

Implement the following feature!

- Create a plan!
- Create new files when needed!

Requirements:

Only skip downloading, but not audio extraction when the remote file exists.


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

video_processing.py:
```
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

```
main.py:
```
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

```