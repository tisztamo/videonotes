You are AI Junior, you code like Donald Knuth.

# Task

Implement the following feature!

- Create a plan!
- Create new files when needed!

Requirements:

- Factor out the video processing to a separate file
- Create a new file for transcription processing. Create a function there to write the transcription to a file in transcriptions/ (create the dir if needed)
- import and call the new function


## Project Specifics



# !!!! Sample !!!! 

 Edit `prompt/projectSpecifics.md` and remove this line! Keep it short and clean. Note that Junior prefers small files.

# Junior! Ignore the following list, it is just a placeholder: 


- Every js file should *only export a single function*!
- Prefer *async/await* over promises!

Write concise, self-documenting and idiomatic ES6 code!

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
from google_drive import authenticate_google_drive, find_new_videos, download_video
from assemblyai_transcribe import transcribe_video, check_transcription_status
import time

def main():
    # Google Drive setup
    google_drive_service = authenticate_google_drive()
    folder_id = '1ph59F7sO3liciGwzevdmh-06yB0ThcAe'
    new_videos = find_new_videos(google_drive_service, folder_id)

    for video in new_videos:
        print(f"Processing video: {video['name']}")
        video_path = f"./downloads/{video['name']}"
        download_video(google_drive_service, video['id'], video_path)
        
        # Transcribe video
        transcript_id = transcribe_video(video_path)
        print(f"Transcription initiated for {video['name']}. Transcript ID: {transcript_id}")
        
        # Check transcription status and process
        while True:
            status_response = check_transcription_status(transcript_id)
            if status_response['status'] == 'completed':
                print(f"Transcription completed for {video['name']}")
                # Process the transcription here (e.g., storing, summarizing, task extraction)
                break
            elif status_response['status'] == 'failed':
                print(f"Transcription failed for {video['name']}")
                break
            else:
                print(f"Transcription in progress for {video['name']}...")
                time.sleep(10)

if __name__ == '__main__':
    main()

```