#!/bin/sh

set -e

goal="Extract tasks from summaries to files"

echo "Plan:"

echo "1. Identify key points in the working set."
echo "2. Plan the feature to extract tasks from summaries using an LLM."
echo "3. Create the 'tasks/' directory and write tasks to individual files."

# Create a new Python file for extracting tasks from summaries
cat > videonotes/task_extraction.py << EOF
import os
from .llm.openai.openai_chat import chat_with_openai

def extract_tasks_from_summary(summary_filename):
    """
    Extract tasks from the summary using an LLM and write them to files in the 'tasks/' directory.
    """
    with open(summary_filename, 'r') as f:
        summary = f.read()
    
    # Generate a list of tasks in a simple to parse form
    task_prompt = "Generate a list of tasks based on the following summary:\n" + summary
    tasks = chat_with_openai(task_prompt).split('\n') # Assuming each task is on a new line

    os.makedirs('./tasks/', exist_ok=True)

    # Write each task to a separate file within 'tasks/' directory
    for i, task in enumerate(tasks, start=1):
        task_filename = f"./tasks/task_{i}.txt"
        with open(task_filename, 'w') as f:
            f.write(task)
        print(f"Task written to {task_filename}")
EOF

# Modify main.py to incorporate the task extraction feature
cat > main.py << EOF
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

    # Extract tasks from summaries and write to files
    for summary_filename in summary_filenames:
        extract_tasks_from_summary(summary_filename)

    print(summary_filenames)

if __name__ == '__main__':
    main()
EOF

echo "\033[32mDone: $goal\033[0m\n"
