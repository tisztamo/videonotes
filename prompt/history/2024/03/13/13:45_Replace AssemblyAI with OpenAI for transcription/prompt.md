You are AI Junior, you code like Donald Knuth.

# Task

Implement the following feature!

- Create a plan!
- Create new files when needed!

Requirements:

Instead of assemblyai, use openai api to transcribe. create a new file for it. OPEANAI_API_KEY env var is set. 


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

transcription_processing.py:
```
import os
from assemblyai_transcribe import transcribe_audio, check_transcription_status
import time

def process_transcriptions(videos):
    for video, audio_path in videos:
        transcript_id = transcribe_audio(audio_path)
        print(f"Transcription initiated for {video['name']}. Transcript ID: {transcript_id}")
        
        while True:
            status_response = check_transcription_status(transcript_id)
            if status_response['status'] == 'completed':
                print(f"Transcription completed for {video['name']}")
                write_transcription_to_file(video, status_response['text'])
                break
            elif status_response['status'] == 'failed' or status_response['status'] == 'error':
                print(f"Transcription failed for {video['name']}")
                break
            else:
                print(f"Transcription in progress for {video['name']}...")
                time.sleep(10)
                
def write_transcription_to_file(video, transcript):
    os.makedirs('transcriptions', exist_ok=True)
    filename = f"transcriptions/{os.path.splitext(video['name'])[0]}.txt"
    with open(filename, 'w') as f:
        f.write(transcript)
    print(f"Transcription written to {filename}")

```
assemblyai_transcribe.py:
```
import requests
import os

api_key = os.environ.get('ASSEMBLYAI_API_KEY')
upload_endpoint = 'https://api.assemblyai.com/v2/upload'
transcript_endpoint = 'https://api.assemblyai.com/v2/transcript'

def transcribe_audio(audio_path):
    def read_file(audio_path, chunk_size=5242880):
        with open(audio_path, 'rb') as _file:
            while True:
                data = _file.read(chunk_size)
                if not data:
                    break
                yield data
    headers = {'authorization': api_key}
    upload_response = requests.post(upload_endpoint, headers=headers, data=read_file(audio_path))
    audio_url = upload_response.json()['upload_url']
    transcript_request = {'audio_url': audio_url}
    transcript_response = requests.post(transcript_endpoint, json=transcript_request, headers=headers)
    transcript_id = transcript_response.json()['id']
    return transcript_id

def check_transcription_status(transcript_id):
    headers = {'authorization': api_key}
    endpoint = f"https://api.assemblyai.com/v2/transcript/{transcript_id}"
    response = requests.get(endpoint, headers=headers)
    return response.json()

```