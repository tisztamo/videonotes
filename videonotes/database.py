import sqlite3
import os

DB_NAME = 'googledrive.db'

def create_database():
    if not os.path.exists(DB_NAME):
        conn = sqlite3.connect(DB_NAME)
        c = conn.cursor()
        c.execute('''CREATE TABLE files
                     (id TEXT PRIMARY KEY, name TEXT, created DATETIME, modified DATETIME, size INTEGER)''')
        conn.commit()
        conn.close()

def file_processed(file_id):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("SELECT COUNT(*) FROM files WHERE id = ?", (file_id,))
    count = c.fetchone()[0]
    conn.close()
    return count > 0

def mark_file_processed(file_id, file_name, created, modified, size):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("INSERT OR REPLACE INTO files VALUES (?, ?, ?, ?, ?)", 
              (file_id, file_name, created, modified, size))
    conn.commit()
    conn.close()
