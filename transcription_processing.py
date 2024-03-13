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
