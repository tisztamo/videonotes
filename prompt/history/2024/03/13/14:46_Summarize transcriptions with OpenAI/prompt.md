You are AI Junior, you code like Donald Knuth.

# Task

Implement the following feature!

- Create a plan!
- Create new files when needed!

Requirements:

After transcriptions are ready, clean and sumamrize them to ./summaries/ (create the dir in python before writing to it) using an openai api call with 3.5 model. Use a prompt that ensures the summaries contain all information from the transcipt.


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

main.py:
```
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

```
transcription_processing.py:
```
import os
from openai_transcribe import transcribe_audio, check_transcription_status

def process_transcriptions(videos):
    transcription_filenames = []
    for video, audio_path in videos:
        transcript = transcribe_audio(audio_path)
        print(f"Transcription completed for {video['name']}")
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
openai_transcribe.py:
```
import os
from openai import OpenAI

client = OpenAI()

def transcribe_audio(audio_path):
    with open(audio_path, "rb") as audio_file:
        transcript = client.audio.transcriptions.create(
              model="whisper-1", 
              file=audio_file,
        )
    return transcript

def check_transcription_status(transcript):
    # OpenAI transcription is synchronous, so no need to check status
    return {'status': 'completed', 'text': transcript.text}

```