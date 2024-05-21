from openai import OpenAI
from videonotes.tools.memoizer import memoize

client = OpenAI()

@memoize("gpt-4o")
def chat_with_openai(prompt):
    message = {
        'role': 'user',
        'content': prompt
    }

    response = client.chat.completions.create(
        model="gpt-4o", #"gpt-3.5-turbo",
        messages=[message],
        max_tokens=2000
    )

    chatbot_response = response.choices[0].message.content
    return chatbot_response.strip()
