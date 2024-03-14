#!/bin/sh
set -e

goal="Extract tasks from summaries using LLM"

echo "Plan:"
echo "1. Add function to extract tasks from summaries"
echo "2. Call task extraction after summaries are generated"
echo "3. Write extracted tasks to files in tasks/ directory"

cat > videonotes/task_extraction.py << EOF
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
    tasks = tasks_str.split('\\n')
    
    os.makedirs('./tasks/', exist_ok=True)
    basename = os.path.basename(summary_filename)
    tasks_filename = f"./tasks/{basename}.tasks"
    with open(tasks_filename, 'w') as f:
        f.write('\\n'.join(tasks))
    
    print(f"Extracted {len(tasks)} tasks to {tasks_filename}")
    return tasks_filename
EOF

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
    print(summary_filenames)

    task_filenames = list(map(extract_tasks_from_summary, summary_filenames))
    print(task_filenames)

if __name__ == '__main__':
    main()
EOF

echo "\033[32mDone: $goal\033[0m\n"