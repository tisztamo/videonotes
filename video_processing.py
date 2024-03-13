import os
from google_drive import authenticate_google_drive, find_new_videos, download_video

def download_videos(google_drive_service, folder_id):
    new_videos = find_new_videos(google_drive_service, folder_id)
    for video in new_videos:
        print(f"Processing video: {video['name']}")
        video_path = f"./downloads/{video['name']}"
        download_video(google_drive_service, video['id'], video_path)
        
        audio_path = extract_audio(video_path)
        yield video, audio_path

def extract_audio(video_path):
    audio_path = os.path.splitext(video_path)[0] + ".wav"
    os.system(f"ffmpeg -i {video_path} -vn -acodec pcm_s16le -ar 44100 -ac 2 {audio_path}")
    return audio_path
