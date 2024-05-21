You are AI Junior, you code like Donald Knuth.

# Task

Implement the following feature!

- Create a plan!
- Create new files when needed!

Requirements:

Create an sqlite-based function memoizer in videonotes/tools/memoizer.py  and use it in openai chat. Open or create a db file named after the chat model.


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

videonotes/llm/openai/openai_chat.py:
```
from openai import OpenAI

client = OpenAI()

def chat_with_openai(prompt):
    message = {
        'role': 'user',
        'content': prompt
    }

    response = client.chat.completions.create(
        model="gpt-4o", #"gpt-3.5-turbo",
        messages=[message],
        max_tokens=2000
    )

    chatbot_response = response.choices[0].message.content
    return chatbot_response.strip()

```