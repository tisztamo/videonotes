import os
from .llm.openai.openai_transcribe import transcribe_audio

def process_transcriptions(videos):
    transcription_filenames = []
    for video, video_path, audio_path in videos:
        print(f"Transcription starting for {video['name']}")
        transcript = transcribe_audio(audio_path)
        transcription_filename = write_transcription_to_file(video, transcript.text)
        transcription_filenames.append(transcription_filename)
    return transcription_filenames

def write_transcription_to_file(video, transcript):
    os.makedirs('transcriptions', exist_ok=True)
    filename = f"transcriptions/{os.path.splitext(video['name'])[0]}.txt"
    with open(filename, 'w') as f:
        f.write(transcript)
    print(f"Transcription written to {filename}")
    return filename
