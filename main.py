from google_drive import authenticate_google_drive
from video_processing import download_videos, extract_audio
from transcription_processing import process_transcriptions

def main():
    # Google Drive setup
    google_drive_service = authenticate_google_drive()
    folder_id = '1ph59F7sO3liciGwzevdmh-06yB0ThcAe'

    # Download new videos
    video_paths = []
    for video, video_path in download_videos(google_drive_service, folder_id):
        audio_path = extract_audio(video_path)
        video_paths.append((video, audio_path))

    # Process transcriptions for downloaded videos
    process_transcriptions(video_paths)

if __name__ == '__main__':
    main()
