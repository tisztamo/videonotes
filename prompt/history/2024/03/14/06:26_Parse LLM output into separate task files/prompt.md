You are AI Junior, you code like Donald Knuth.

# Task

Implement the following feature!

- Create a plan!
- Create new files when needed!

Requirements:

Parse the llm output and create separate files for every task. in main, collect all the created task filenames.


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
from videonotes.google_drive import authenticate_google_drive
from videonotes.video_processing import download_videos, extract_audio
from videonotes.transcription_processing import process_transcriptions  
from videonotes.summary_processing import summarize_transcription
from videonotes.task_extraction import extract_tasks_from_summary

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

    summary_filenames = list(map(summarize_transcription, transcription_filenames))
    print(summary_filenames)

    task_filenames = list(map(extract_tasks_from_summary, summary_filenames))
    print(task_filenames)

if __name__ == '__main__':
    main()

```
videonotes/task_extraction.py:
```
import os
from .llm.openai.openai_chat import chat_with_openai

def extract_tasks_from_summary(summary_filename):
    print(f"Extracting tasks from {summary_filename}")
    with open(summary_filename, 'r') as f:
        summary = f.read()
    
    prompt = f"""Extract all tasks from the following summary. 
Output the tasks as a numbered list in the following format:
1. First task
2. Second task
...

Summary:
{summary}
"""
    
    tasks_str = chat_with_openai(prompt)
    tasks = tasks_str.split('\n')
    
    os.makedirs('./tasks/', exist_ok=True)
    basename = os.path.basename(summary_filename)
    tasks_filename = f"./tasks/{basename}.tasks"
    with open(tasks_filename, 'w') as f:
        f.write('\n'.join(tasks))
    
    print(f"Extracted {len(tasks)} tasks to {tasks_filename}")
    return tasks_filename

```