#!/bin/sh
set -e

goal="Add SQLite DB to track downloaded files"

echo "Plan:"
echo "1. Create SQLite database file if it doesn't exist"
echo "2. Add function to insert file info into database" 
echo "3. Update download_videos() to insert file info on successful download"
echo "4. Add function to check if file exists in database before downloading"

cat > videonotes/database.py << EOF
import sqlite3
import os

DB_NAME = 'googledrive.db'

def create_database():
    if not os.path.exists(DB_NAME):
        conn = sqlite3.connect(DB_NAME)
        c = conn.cursor()
        c.execute('''CREATE TABLE files
                     (id TEXT PRIMARY KEY, name TEXT, created DATETIME, modified DATETIME, size INTEGER)''')
        conn.commit()
        conn.close()

def file_exists(file_id):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("SELECT COUNT(*) FROM files WHERE id = ?", (file_id,))
    count = c.fetchone()[0]
    conn.close()
    return count > 0

def insert_file(file_id, file_name, created, modified, size):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("INSERT OR REPLACE INTO files VALUES (?, ?, ?, ?, ?)", 
              (file_id, file_name, created, modified, size))
    conn.commit()
    conn.close()
EOF

cat > videonotes/google_drive.py << EOF
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow  
from google.auth.transport.requests import Request
from googleapiclient.http import MediaIoBaseDownload
import pickle
import os.path
from videonotes.database import create_database, file_exists, insert_file

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
    if not file_exists(file_id):
        request = service.files().get_media(fileId=file_id)
        fh = open(file_name, 'wb')
        downloader = MediaIoBaseDownload(fh, request)
        done = False
        while not done:
            status, done = downloader.next_chunk()
            print("Download %d%%." % int(status.progress() * 100))
        fh.close()
        
        file_metadata = service.files().get(fileId=file_id, fields='name,createdTime,modifiedTime,size').execute()
        insert_file(file_id, file_metadata['name'], file_metadata['createdTime'], 
                    file_metadata['modifiedTime'], int(file_metadata['size']))
    else:
        print(f"File {file_name} already downloaded, skipping...")
        
def get_video_size(service, file_id):
    file_metadata = service.files().get(fileId=file_id, fields='size').execute()
    return int(file_metadata['size'])

def find_new_videos(service, folder_id):
    query = f"('{folder_id}' in parents and (mimeType='video/mp4' or mimeType='video/quicktime' or mimeType='video/x-msvideo' or mimeType='video/x-ms-wmv') and trashed=false)"
    return find_videos(service, query)
EOF

cat > main.py << EOF  
from videonotes.google_drive import authenticate_google_drive
from videonotes.video_processing import download_videos, extract_audio
from videonotes.transcription_processing import process_transcriptions  
from videonotes.summary_processing import summarize_transcription
from videonotes.task_extraction import extract_tasks_from_summary
from videonotes.database import create_database

def main():
    # Create database if it doesn't exist
    create_database()
    
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