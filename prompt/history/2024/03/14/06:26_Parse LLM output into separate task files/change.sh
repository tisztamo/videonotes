#!/bin/sh
set -e
goal="Parse LLM output into separate task files"

echo "Plan:"
echo "1. Modify extract_tasks_from_summary to parse tasks into separate files"
echo "2. In main, collect all created task filenames"

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
    tasks = tasks_str.split('\n')
    
    os.makedirs('./tasks/', exist_ok=True)
    basename = os.path.splitext(os.path.basename(summary_filename))[0]
    
    task_filenames = []
    for i, task in enumerate(tasks, start=1):
        task_filename = f"./tasks/{basename}_task{i}.txt"
        with open(task_filename, 'w') as f:
            f.write(task.strip())
        task_filenames.append(task_filename)
    
    print(f"Extracted {len(tasks)} tasks to ./tasks/")
    return task_filenames
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

    all_task_filenames = []
    for summary_filename in summary_filenames:
        task_filenames = extract_tasks_from_summary(summary_filename)
        all_task_filenames.extend(task_filenames)

    print(f"Created {len(all_task_filenames)} task files:")
    print('\n'.join(all_task_filenames))

if __name__ == '__main__':
    main()
EOF

echo "\033[32mDone: $goal\033[0m\n"