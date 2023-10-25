# SSH the VM and add this file
# nano app.py
# python3 app.py

from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_cloud():
  return 'Hello Cloud!'

app.run(host='0.0.0.0')
