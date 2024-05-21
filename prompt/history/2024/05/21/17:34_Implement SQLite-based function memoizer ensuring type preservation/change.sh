#!/bin/sh
set -e
goal="Implement SQLite-based function memoizer ensuring type preservation"
echo "Plan:"
echo "1. Create memoizer.py in videonotes/tools."
echo "2. Implement memoizer functionality using SQLite and pickle."
echo "3. Modify openai_chat.py to use the memoizer."

# Step 1: Ensure the directory structure exists
mkdir -p videonotes/tools

# Step 2: Create memoizer.py with memoizer implementation
cat > videonotes/tools/memoizer.py << 'EOF'
import sqlite3
import os
import hashlib
import pickle

def get_db_path(model_name):
    db_filename = f"{model_name}.db"
    db_path = os.path.join(os.path.dirname(__file__), db_filename)
    return db_path

def memoize(model_name):
    def decorator(func):
        def wrapper(*args, **kwargs):
            db_path = get_db_path(model_name)
            conn = sqlite3.connect(db_path)
            cursor = conn.cursor()
            
            # Create table if it doesn't exist
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS memoizer (
                    id TEXT PRIMARY KEY,
                    result BLOB
                )
            ''')
            
            # Create a unique key based on function name and arguments
            key = f"{func.__name__}:{args}:{kwargs}"
            key_hash = hashlib.sha256(key.encode()).hexdigest()
            
            # Check if result is already cached
            cursor.execute('SELECT result FROM memoizer WHERE id = ?', (key_hash,))
            row = cursor.fetchone()
            if row:
                result = pickle.loads(row[0])
                conn.close()
                return result
            
            # Call the actual function and store the result
            result = func(*args, **kwargs)
            cursor.execute('INSERT INTO memoizer (id, result) VALUES (?, ?)', (key_hash, pickle.dumps(result)))
            conn.commit()
            conn.close()
            return result
        return wrapper
    return decorator
EOF

# Step 3: Modify openai_chat.py to use the memoizer
cat > videonotes/llm/openai/openai_chat.py << 'EOF'
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
EOF

echo "\033[32mDone: $goal\033[0m\n"
