from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow  
from google.auth.transport.requests import Request
from googleapiclient.http import MediaIoBaseDownload
import pickle
import os.path
from videonotes.database import file_processed

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

def execute_query(service, query):
    results = service.files().list(q=query, spaces='drive', 
                                   fields='nextPageToken, files(id, name)').execute()
    items = results.get('files', [])
    
    if not items:
        print('No files found.')
    
    return items

def download_video(service, file_id, file_name):
    if not file_processed(file_id):
        request = service.files().get_media(fileId=file_id)
        fh = open(file_name, 'wb')
        downloader = MediaIoBaseDownload(fh, request)
        done = False
        while not done:
            status, done = downloader.next_chunk()
            print("Download %d%%." % int(status.progress() * 100))
        fh.close()
    else:
        print(f"File {file_name} already downloaded, skipping...")
        
def get_video_size(service, file_id):
    file_metadata = service.files().get(fileId=file_id, fields='size').execute()
    return int(file_metadata['size'])

def find_new_media(service, folder_id):
    query = (
        f"('{folder_id}' in parents and ("
        f"mimeType='video/mp4' or "
        f"mimeType='video/quicktime' or "
        f"mimeType='video/x-msvideo' or "
        f"mimeType='video/x-ms-wmv' or "
        f"mimeType='audio/mpeg' or "
        f"mimeType='audio/wav' or "
        f"mimeType='audio/aac' or "
        f"mimeType='audio/flac' or "
        f"mimeType='audio/mp4' or "
        f"mimeType='audio/ogg' or "
        f"mimeType='audio/webm'"
        f") and trashed=false)"
    )
    all_media = execute_query(service, query)
    return filter(lambda media: not file_processed(media["id"]), all_media)
