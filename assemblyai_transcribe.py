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
