#!/bin/sh

set -e

goal="Improve task prompt for detailed task extraction"

echo "Plan:"

echo "1. Refine task extraction prompt for clarity and detail."
echo "2. Ensure tasks extracted are directly described in the summary with all details included."
echo "3. Format output so there is one task per line for easier parsing and file writing."

# Update the task extraction feature in task_extraction.py with an improved prompt
cat > videonotes/task_extraction.py << EOF
import os
from .llm.openai.openai_chat import chat_with_openai

def extract_tasks_from_summary(summary_filename):
    """
    Extract tasks from the summary using an improved LLM prompt to ensure tasks are detailed and clearly defined,
    directly described in the summary with all details included, and formatted one task per line.
    """
    with open(summary_filename, 'r') as f:
        summary = f.read()
    
    # Improved prompt for task extraction
    task_prompt = "Read the following summary and list all the specific tasks mentioned, with all their details. Provide each task on a new line, ensuring clarity and completeness in the description:\n" + summary
    tasks = chat_with_openai(task_prompt).split('\n') # Assuming each task is on a new line

    os.makedirs('./tasks/', exist_ok=True)

    # Write each task to a separate file within 'tasks/' directory
    for i, task in enumerate(tasks, start=1):
        if task.strip(): # Ensure the task is not empty
            task_filename = f"./tasks/task_{i}.txt"
            with open(task_filename, 'w') as f:
                f.write(task)
            print(f"Task written to {task_filename}")
EOF

echo "\033[32mDone: $goal\033[0m\n"
