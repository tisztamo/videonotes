import os
from .llm.openai.openai_chat import chat_with_openai

def summarize_transcription(transcription_filename):
    print(f"Summarizing {transcription_filename}")
    with open(transcription_filename, 'r') as f:
        transcript = f.read()
    
    summary = chat_with_openai(f"""Clean the following transcript, remove redundant information, simplify word use, but retain all information. Output the cleaned transcript in english.
<transcript>{transcript}</transcript>""")

    os.makedirs('./summaries/', exist_ok=True)
    summary_filename = f"./summaries/{os.path.basename(transcription_filename)}"
    with open(summary_filename, 'w') as f:
        f.write(summary)
    print(f"Summary written to {summary_filename}")
    return summary_filename

