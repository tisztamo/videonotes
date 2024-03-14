from videonotes.google_drive import authenticate_google_drive
from videonotes.video_processing import download_videos, extract_audio
from videonotes.transcription_processing import process_transcriptions  
from videonotes.summary_processing import summarize_transcription
from videonotes.task_extraction import extract_tasks_from_summary

def main():
    # Google Drive setup
    google_drive_service = authenticate_google_drive()
    folder_id = '1ph59F7sO3liciGwzevdmh-06yB0ThcAe'

    # Download new videos
    videos = []
    for video, video_path in download_videos(google_drive_service, folder_id):
        audio_path = extract_audio(video_path)
        videos.append((video, video_path, audio_path))

    # Process transcriptions for downloaded videos
    transcription_filenames = process_transcriptions(videos)
    summary_filenames = list(map(summarize_transcription, transcription_filenames))
    print(summary_filenames)

    all_task_filenames = []
    for summary_filename in summary_filenames:
        task_filenames = extract_tasks_from_summary(summary_filename)
        all_task_filenames.extend(task_filenames)

    print(f"Created {len(all_task_filenames)} task files:")
    print('\n'.join(all_task_filenames))

if __name__ == '__main__':
    main()
