#!/bin/sh
set -e

goal="Find videos excluding deleted ones on Google Drive"

echo "Plan:"  
echo "1. Add trashed=false to the query to exclude deleted videos"
echo "2. Refactor find_new_videos to take a query parameter"
echo "3. Update the query in the authenticate_google_drive function"

cat > videonotes/google_drive.py << EOF
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

def find_videos(service, query):
    results = service.files().list(q=query, spaces='drive', 
                                   fields='nextPageToken, files(id, name)').execute()
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

def find_new_videos(service, folder_id):
    query = f"('{folder_id}' in parents and (mimeType='video/mp4' or mimeType='video/quicktime' or mimeType='video/x-msvideo' or mimeType='video/x-ms-wmv') and trashed=false)"
    return find_videos(service, query)
EOF

echo "\033[32mDone: $goal\033[0m\n"