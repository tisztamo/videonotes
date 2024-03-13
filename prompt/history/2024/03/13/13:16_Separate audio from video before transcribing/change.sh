#!/bin/sh
set -e

goal="Separate audio from video before transcribing"

echo "Plan:"
echo "1. Update video_processing.py to extract audio"
echo "2. Update transcription_processing.py to use audio file"

# Update video_processing.py
cat > video_processing.py << EOF
import os
from google_drive import authenticate_google_drive, find_new_videos, download_video

def download_videos(google_drive_service, folder_id):
    new_videos = find_new_videos(google_drive_service, folder_id)
    for video in new_videos:
        print(f"Processing video: {video['name']}")
        video_path = f"./downloads/{video['name']}"
        download_video(google_drive_service, video['id'], video_path)
        
        audio_path = extract_audio(video_path)
        yield video, audio_path

def extract_audio(video_path):
    audio_path = os.path.splitext(video_path)[0] + ".wav"
    os.system(f"ffmpeg -i {video_path} -vn -acodec pcm_s16le -ar 44100 -ac 2 {audio_path}")
    return audio_path
EOF

# Update transcription_processing.py 
cat > transcription_processing.py << EOF
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
EOF

# Update assemblyai_transcribe.py
cat > assemblyai_transcribe.py << EOF
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
EOF

echo "\033[32mDone: $goal\033[0m\n"