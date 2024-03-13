#!/bin/sh
set -e

goal="Fix NameError in openai_transcribe.py"

echo "Plan:"
echo "1. Update openai_transcribe.py to import the openai module correctly."

cat > openai_transcribe.py << EOF
import os
import openai

openai.api_key = os.environ.get('OPENAI_API_KEY')

def transcribe_audio(audio_path):
    with open(audio_path, "rb") as audio_file:
        transcript = openai.Audio.transcribe("whisper-1", audio_file)
    return transcript

def check_transcription_status(transcript):
    # OpenAI transcription is synchronous, so no need to check status
    return {'status': 'completed', 'text': transcript.text}
EOF

echo "\033[32mDone: $goal\033[0m\n"