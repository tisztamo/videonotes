from google_drive import authenticate_google_drive
from video_processing import download_videos
from transcription_processing import process_transcriptions

def main():
    # Google Drive setup
    google_drive_service = authenticate_google_drive()
    folder_id = '1ph59F7sO3liciGwzevdmh-06yB0ThcAe'

    # Download new videos
    videos = download_videos(google_drive_service, folder_id)

    # Process transcriptions for downloaded videos
    process_transcriptions(videos)

if __name__ == '__main__':
    main()
