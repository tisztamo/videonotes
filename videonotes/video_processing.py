import os

from videonotes.google_drive import find_new_media, download_video, get_video_size

def download_media(google_drive_service, folder_id):
    all_videos = find_new_media(google_drive_service, folder_id)
    for video in all_videos:
        print(f"Found video: {video['name']}")
        video_path = f"./downloads/{video['name']}"
        
        # Get remote video size
        remote_size = get_video_size(google_drive_service, video['id'])
        
        # Check if local video exists and compare sizes
        if os.path.exists(video_path):
            local_size = os.path.getsize(video_path)
            if local_size == remote_size:
                print(f"Skipping {video['name']}, already downloaded with same size")
                yield video, video_path
                continue
        
        download_video(google_drive_service, video['id'], video_path)
        yield video, video_path

def extract_audio(media_path):
    audio_path = os.path.splitext(media_path)[0] + ".mp3"
    if not os.path.exists(audio_path):
        os.system(f"ffmpeg -i '{media_path}' -vn -ar 44100 -ac 2 -ab 48k -f mp3 '{audio_path}'")
    return audio_path
