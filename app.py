from flask import Flask
import markdown

app = Flask(__name__)

@app.route('/')
def hello():
    with open('README.md', 'r', encoding='utf-8') as f:
      md_text = f.read()
      return markdown.markdown(md_text, extensions=['fenced_code'])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005)
