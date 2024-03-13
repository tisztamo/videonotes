#!/bin/sh
set -e
goal="Replace AssemblyAI with OpenAI for transcription"
echo "Plan:"
echo "1. Create a new file openai_transcribe.py for OpenAI transcription functionality"
echo "2. Modify transcription_processing.py to use openai_transcribe instead of assemblyai_transcribe"
echo "3. Remove assemblyai_transcribe.py as it's no longer needed"

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
    return {'status': 'completed', 'text': transcript['text']}
EOF

cat > transcription_processing.py << EOF
import os
from openai_transcribe import transcribe_audio, check_transcription_status

def process_transcriptions(videos):
    for video, audio_path in videos:
        transcript = transcribe_audio(audio_path)
        print(f"Transcription completed for {video['name']}")
        write_transcription_to_file(video, transcript['text'])
                
def write_transcription_to_file(video, transcript):
    os.makedirs('transcriptions', exist_ok=True)
    filename = f"transcriptions/{os.path.splitext(video['name'])[0]}.txt"
    with open(filename, 'w') as f:
        f.write(transcript)
    print(f"Transcription written to {filename}")
EOF

rm assemblyai_transcribe.py

echo "\033[32mDone: $goal\033[0m\n"