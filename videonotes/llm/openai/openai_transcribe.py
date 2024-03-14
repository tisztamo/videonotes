import os
from openai import OpenAI

client = OpenAI()

def transcribe_audio(audio_path):
    with open(audio_path, "rb") as audio_file:
        transcript = client.audio.transcriptions.create(
              model="whisper-1", 
              file=audio_file,
        )
    return transcript
