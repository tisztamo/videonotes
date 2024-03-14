import os
from openai import OpenAI

client = OpenAI()

def chat_with_openai(prompt):
    message = {
        'role': 'user',
        'content': prompt
    }

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[message],
        max_tokens=1500
    )

    chatbot_response = response.choices[0].message.content
    return chatbot_response.strip()

def summarize_transcription(transcription_filename):
    print(f"Summarizing {transcription_filename}")
    with open(transcription_filename, 'r') as f:
        transcript = f.read()
    
    summary = chat_with_openai(f"Clean this transcript, remove redundant information, simplify word use, but retain all information. Output the cleaned transcript in english.\n{transcript}")

    os.makedirs('./summaries/', exist_ok=True)
    summary_filename = f"./summaries/{os.path.basename(transcription_filename)}"
    with open(summary_filename, 'w') as f:
        f.write(summary)
    print(f"Summary written to {summary_filename}")
    return summary_filename

