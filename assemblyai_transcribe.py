import requests
import os

# Use the environment variable for the AssemblyAI API key
assemblyai_api_key = os.getenv('ASSEMBLYAI_API_KEY')

def transcribe_video(video_file_path):
    headers = {'authorization': assemblyai_api_key}
    response = requests.post('https://api.assemblyai.com/v2/upload', headers=headers, files={'file': open(video_file_path, 'rb')})
    audio_url = response.json()['upload_url']
    json = {"audio_url": audio_url}
    transcript_response = requests.post('https://api.assemblyai.com/v2/transcript', json=json, headers=headers)
    transcript_id = transcript_response.json()['id']
    print('Transcription ID:', transcript_id)
    return transcript_id

def check_transcription_status(transcript_id):
    headers = {'authorization': assemblyai_api_key}
    endpoint = f'https://api.assemblyai.com/v2/transcript/{transcript_id}'
    result = requests.get(endpoint, headers=headers)
    return result.json()
