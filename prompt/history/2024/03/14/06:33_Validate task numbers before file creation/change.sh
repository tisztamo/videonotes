#!/bin/sh
set -e
goal="Validate task numbers before file creation"
echo "Plan:"
echo "1. Modify task_extraction.py to include task number validation."
echo "2. Ensure error handling and concise, idiomatic code."
echo "3. Keep functionalities separated in modular files."

# Modify task_extraction.py
cat > videonotes/task_extraction.py << EOF
import os
import re
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
    basename = os.path.splitext(os.path.basename(summary_filename))[0]

    task_filenames = []
    for i, task in enumerate(tasks):
        match = re.match(r"^(\d+)\. ", task)
        if match and int(match.group(1)) == i + 1:
            task_filename = f"./tasks/{basename}_task{i+1}.txt"
            with open(task_filename, 'w') as f:
                f.write(task.strip())
            task_filenames.append(task_filename)
        else:
            print("\\033[31mError: Task number does not match the expected sequence number. Skipping: \\" + task + "\\"\\033[0m")

    print(f"Extracted {len(task_filenames)} tasks to ./tasks/")
    return task_filenames
EOF
echo "\033[32mDone: $goal\033[0m\n"
