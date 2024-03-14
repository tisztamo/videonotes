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
