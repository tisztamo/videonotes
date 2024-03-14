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

    task_filenames = list(map(extract_tasks_from_summary, summary_filenames))
    print(task_filenames)

if __name__ == '__main__':
    main()
