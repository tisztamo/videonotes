import os
from openai_transcribe import transcribe_audio, check_transcription_status

def process_transcriptions(videos):
    for video, audio_path in videos:
        transcript = transcribe_audio(audio_path)
        print(f"Transcription completed for {video['name']}")
        write_transcription_to_file(video, transcript.text)
                
def write_transcription_to_file(video, transcript):
    os.makedirs('transcriptions', exist_ok=True)
    filename = f"transcriptions/{os.path.splitext(video['name'])[0]}.txt"
    with open(filename, 'w') as f:
        f.write(transcript)
    print(f"Transcription written to {filename}")
