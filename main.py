from google_drive import authenticate_google_drive, find_new_videos, download_video
from assemblyai_transcribe import transcribe_video, check_transcription_status
import time

def main():
    # Google Drive setup
    google_drive_service = authenticate_google_drive()
    folder_id = '1ph59F7sO3liciGwzevdmh-06yB0ThcAe'
    new_videos = find_new_videos(google_drive_service, folder_id)

    for video in new_videos:
        print(f"Processing video: {video['name']}")
        video_path = f"./downloads/{video['name']}"
        download_video(google_drive_service, video['id'], video_path)
        
        # Transcribe video
        transcript_id = transcribe_video(video_path)
        print(f"Transcription initiated for {video['name']}. Transcript ID: {transcript_id}")
        
        # Check transcription status and process
        while True:
            status_response = check_transcription_status(transcript_id)
            if status_response['status'] == 'completed':
                print(f"Transcription completed for {video['name']}")
                # Process the transcription here (e.g., storing, summarizing, task extraction)
                break
            elif status_response['status'] == 'failed':
                print(f"Transcription failed for {video['name']}")
                break
            else:
                print(f"Transcription in progress for {video['name']}...")
                time.sleep(10)

if __name__ == '__main__':
    main()
