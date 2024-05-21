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
            
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS memoizer (
                    id TEXT PRIMARY KEY,
                    result BLOB
                )
            ''')
            
            key = f"{func.__name__}:{args}:{kwargs}"
            key_hash = hashlib.sha256(key.encode()).hexdigest()
            
            cursor.execute('SELECT result FROM memoizer WHERE id = ?', (key_hash,))
            row = cursor.fetchone()
            if row:
                result = pickle.loads(row[0])
                conn.close()
                return result
            
            result = func(*args, **kwargs)
            cursor.execute('INSERT INTO memoizer (id, result) VALUES (?, ?)', (key_hash, pickle.dumps(result)))
            conn.commit()
            conn.close()
            return result
        return wrapper
    return decorator
