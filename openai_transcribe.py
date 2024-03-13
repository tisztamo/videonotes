import os
from openai import OpenAI

client = OpenAI(api_key=os.environ.get('OPENAI_API_KEY'))


def transcribe_audio(audio_path):
    with open(audio_path, "rb") as audio_file:
        transcript = client.audio.transcribe("whisper-1", audio_file)
    return transcript

def check_transcription_status(transcript):
    # OpenAI transcription is synchronous, so no need to check status
    return {'status': 'completed', 'text': transcript.text}
