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
