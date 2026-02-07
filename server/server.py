import json
import os
import threading
import time
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, 'data')
DB_PATH = os.path.join(DATA_DIR, 'db.json')
PENDING_PATH = os.path.join(DATA_DIR, 'pending.json')
CLIENT_DIST = os.path.join(os.path.dirname(BASE_DIR), 'client', 'dist')

LOCK = threading.Lock()


def utc_now():
  return datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z')


def load_json(path, default):
  if not os.path.exists(path):
    return default
  with open(path, 'r', encoding='utf-8') as f:
    return json.load(f)


def save_json(path, data):
  tmp_path = f"{path}.tmp"
  with open(tmp_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
  os.replace(tmp_path, path)


def process_pending_forever(interval_seconds=2):
  while True:
    try:
      with LOCK:
        pending = load_json(PENDING_PATH, {"items": []})
        if pending.get('items'):
          db = load_json(DB_PATH, {"nextId": 1, "updatedAt": utc_now(), "items": []})
          db['items'].extend(pending['items'])
          db['updatedAt'] = utc_now()
          save_json(DB_PATH, db)
          save_json(PENDING_PATH, {"items": []})
    except Exception:
      pass
    time.sleep(interval_seconds)


class AlkiHandler(SimpleHTTPRequestHandler):
  def _set_headers(self, status=HTTPStatus.OK, content_type='application/json'):
    self.send_response(status)
    self.send_header('Content-Type', content_type)
    self.send_header('Access-Control-Allow-Origin', '*')
    self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    self.send_header('Access-Control-Allow-Headers', 'Content-Type')
    self.end_headers()

  def do_OPTIONS(self):
    self._set_headers(HTTPStatus.NO_CONTENT)

  def do_GET(self):
    parsed = urlparse(self.path)
    if parsed.path == '/api/items':
      with LOCK:
        db = load_json(DB_PATH, {"nextId": 1, "updatedAt": utc_now(), "items": []})
      self._set_headers()
      self.wfile.write(json.dumps({"items": db.get('items', []), "updatedAt": db.get('updatedAt')}).encode('utf-8'))
      return

    if os.path.exists(CLIENT_DIST):
      if parsed.path == '/' or parsed.path == '':
        self.path = '/index.html'
      return super().do_GET()

    self._set_headers(HTTPStatus.NOT_FOUND)
    self.wfile.write(json.dumps({"error": "Build the client first (npm run build)."}).encode('utf-8'))

  def do_POST(self):
    parsed = urlparse(self.path)
    if parsed.path != '/api/items':
      self._set_headers(HTTPStatus.NOT_FOUND)
      self.wfile.write(json.dumps({"error": "Not found"}).encode('utf-8'))
      return

    content_length = int(self.headers.get('Content-Length', '0'))
    payload = self.rfile.read(content_length).decode('utf-8')
    try:
      data = json.loads(payload) if payload else {}
    except json.JSONDecodeError:
      self._set_headers(HTTPStatus.BAD_REQUEST)
      self.wfile.write(json.dumps({"error": "Invalid JSON"}).encode('utf-8'))
      return

    name = str(data.get('name') or 'NEW_CODE')
    item = {
      "id": None,
      "name": name,
      "type": str(data.get('type') or 'UI'),
      "html": str(data.get('html') or ''),
      "css": str(data.get('css') or ''),
      "js": str(data.get('js') or ''),
      "createdAt": utc_now()
    }

    with LOCK:
      db = load_json(DB_PATH, {"nextId": 1, "updatedAt": utc_now(), "items": []})
      pending = load_json(PENDING_PATH, {"items": []})
      item_id = str(db.get('nextId', 1))
      db['nextId'] = int(db.get('nextId', 1)) + 1
      db['updatedAt'] = utc_now()
      item['id'] = item_id
      pending.setdefault('items', []).append(item)
      save_json(DB_PATH, db)
      save_json(PENDING_PATH, pending)

    self._set_headers(HTTPStatus.CREATED)
    self.wfile.write(json.dumps({"item": item}).encode('utf-8'))


def run_server(host='0.0.0.0', port=4177):
  os.chdir(CLIENT_DIST if os.path.exists(CLIENT_DIST) else os.path.dirname(BASE_DIR))
  server = HTTPServer((host, port), AlkiHandler)
  print(f"Alki server running on http://{host}:{port}")
  server.serve_forever()


if __name__ == '__main__':
  thread = threading.Thread(target=process_pending_forever, daemon=True)
  thread.start()
  run_server()
