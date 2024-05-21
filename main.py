from videonotes.google_drive import authenticate_google_drive
from videonotes.video_processing import download_media, extract_audio
from videonotes.transcription_processing import process_transcriptions  
from videonotes.summary_processing import summarize_transcription
from videonotes.task_extraction import extract_tasks_from_summary
from videonotes.database import create_database, mark_file_processed

def main():
    # Create database if it doesn't exist
    create_database()
    
    # Google Drive setup
    google_drive_service = authenticate_google_drive()
    folder_id = '1ph59F7sO3liciGwzevdmh-06yB0ThcAe'
    
    # Download new videos
    videos = []
    for media_file, local_path in download_media(google_drive_service, folder_id):
        audio_path = extract_audio(local_path)
        videos.append((media_file, local_path, audio_path))
    
    # Process transcriptions for downloaded videos  
    transcription_filenames = process_transcriptions(videos)
    summary_filenames = list(map(summarize_transcription, transcription_filenames))
    if len(summary_filenames) > 0:
        print(f"Created {len(summary_filenames)} summary files:")
        print('\n'.join(summary_filenames))
    
    # Extract tasks
    all_task_filenames = []
    for summary_filename in summary_filenames:
        task_filenames = extract_tasks_from_summary(summary_filename)
        all_task_filenames.extend(task_filenames)
    
    if len(all_task_filenames) > 0:
        print(f"Created {len(all_task_filenames)} task files:")
        print('\n'.join(all_task_filenames))

    for media_file, local_path, audio_path in videos:
        file_metadata = google_drive_service.files().get(fileId=media_file['id'], fields='name,createdTime,modifiedTime,size').execute()
        mark_file_processed(media_file['id'], file_metadata['name'], file_metadata['createdTime'], 
                    file_metadata['modifiedTime'], int(file_metadata['size']))


if __name__ == '__main__':
    main()
