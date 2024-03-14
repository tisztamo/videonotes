You are AI Junior, you code like Donald Knuth.

# Task

Implement the following feature!

- Create a plan!
- Create new files when needed!

Requirements:

finding videos should exlcude deleted ones.


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

videonotes/google_drive.py:
```
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.http import MediaIoBaseDownload
import pickle
import os.path

SCOPES = ['https://www.googleapis.com/auth/drive.readonly']

def authenticate_google_drive():
    creds = None
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)
    service = build('drive', 'v3', credentials=creds)
    return service

def find_new_videos(service, folder_id):
    query = f"('{folder_id}' in parents and (mimeType='video/mp4' or mimeType='video/quicktime' or mimeType='video/x-msvideo' or mimeType='video/x-ms-wmv'))"

    print(query)
    results = service.files().list(q=query, spaces='drive',
                                   fields='nextPageToken, files(id, name)').execute()
    print(results)
    items = results.get('files', [])
    if not items:
        print('No files found.')
    else:
        for item in items:
            print(u'{0} ({1})'.format(item['name'], item['id']))
    return items

def download_video(service, file_id, file_name):
    request = service.files().get_media(fileId=file_id)
    fh = open(file_name, 'wb')
    downloader = MediaIoBaseDownload(fh, request)
    done = False
    while not done:
        status, done = downloader.next_chunk()
        print("Download %d%%." % int(status.progress() * 100))
    fh.close()

def get_video_size(service, file_id):
    file_metadata = service.files().get(fileId=file_id, fields='size').execute()
    return int(file_metadata['size'])
```