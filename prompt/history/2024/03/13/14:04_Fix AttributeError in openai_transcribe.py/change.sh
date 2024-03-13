#!/bin/sh
set -e

goal="Fix AttributeError in openai_transcribe.py"

echo "Plan:"
echo "1. Update openai_transcribe.py to use the correct method for transcribing audio with the OpenAI API."

cat > openai_transcribe.py << EOF
import os
from openai import Audio

client = OpenAI(api_key=os.environ.get('OPENAI_API_KEY'))

def transcribe_audio(audio_path):
    with open(audio_path, "rb") as audio_file:
        transcript = client.transcribe("whisper-1", audio_file)
    return transcript

def check_transcription_status(transcript):
    # OpenAI transcription is synchronous, so no need to check status
    return {'status': 'completed', 'text': transcript.text}
EOF

echo "\033[32mDone: $goal\033[0m\n"