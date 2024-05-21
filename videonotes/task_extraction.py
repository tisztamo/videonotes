import os
import re
from .llm.openai.openai_chat import chat_with_openai

def extract_tasks_from_summary(summary_filename):
    print(f"Extracting tasks from {summary_filename}")
    with open(summary_filename, 'r') as f:
        summary = f.read()

    prompt = f"""Extract all tasks from the following voice command summary.
Only list tasks that are specifically mentioned as a task or something we need to do.
Do not list subtasks and anything that is not mentioned as task or todo.
Output the tasks as a numbered list in the following format:
1. First task with all its details. Full task description. No newline.
2. Second task with all its details. Full task description. No newline.
...
Summary:
{summary}
"""

    tasks_str = chat_with_openai(prompt)
    tasks = tasks_str.split('\n')

    os.makedirs('./tasks/', exist_ok=True)
    basename = os.path.splitext(os.path.basename(summary_filename))[0]

    task_filenames = []
    error_count = 0
    for i, task in enumerate(tasks):
        match = re.match(r"^(\d+). (.*)", task)
        if match and int(match.group(1)) + error_count == i + 1:
            task_filename = f"./tasks/{basename}_task{i+1}.txt"
            with open(task_filename, 'w') as f:
                f.write(match.group(2).strip())
            task_filenames.append(task_filename)
        else:
            print('\033[31mError: Task number does not match the expected sequence number. Skipping: \"' + task + '"\"\033[0m')
            error_count = error_count + 1

    print(f"Extracted {len(task_filenames)} tasks to ./tasks/")
    return task_filenames
