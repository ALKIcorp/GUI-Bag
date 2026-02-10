import json
import os
import threading
import time
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse
import traceback

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, 'data')
DB_PATH = os.path.join(DATA_DIR, 'db.json')
PENDING_PATH = os.path.join(DATA_DIR, 'pending.json')
CLIENT_DIST = os.path.join(os.path.dirname(BASE_DIR), 'client', 'dist')

LOCK = threading.Lock()
SCHEMA_VERSION = 1


def utc_now():
  return datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z')


def load_json(path, default):
  if not os.path.exists(path):
    return default
  with open(path, 'r', encoding='utf-8') as f:
    try:
      return json.load(f)
    except json.JSONDecodeError:
      print(f"Warning: Malformed JSON in {path}. Using default data.")
      return default


def save_json(path, data):
  tmp_path = f"{path}.tmp"
  with open(tmp_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
  os.replace(tmp_path, path)

def _initialize_data_files():
  # Initialize db.json
  try:
    db_data = load_json(DB_PATH, None)
    if db_data is None: # File didn't exist or was malformed
      print(f"Initializing {DB_PATH} with default schema.")
      save_json(DB_PATH, ensure_schema({}))
    else:
      # Ensure it has the correct schema, potentially updating it
      db_data = ensure_schema(db_data)
      save_json(DB_PATH, db_data)
  except Exception as e:
    print(f"Error initializing {DB_PATH}: {e}")
    print(traceback.format_exc())
    # Fallback: try to write a fresh default one
    print(f"Attempting to write a fresh default to {DB_PATH}.")
    save_json(DB_PATH, ensure_schema({}))

  # Initialize pending.json
  try:
    pending_data = load_json(PENDING_PATH, None)
    if pending_data is None: # File didn't exist or was malformed
      print(f"Initializing {PENDING_PATH} with default structure.")
      save_json(PENDING_PATH, {"items": []})
  except Exception as e:
    print(f"Error initializing {PENDING_PATH}: {e}")
    print(traceback.format_exc())
    # Fallback: try to write a fresh default one
    print(f"Attempting to write a fresh default to {PENDING_PATH}.")
    save_json(PENDING_PATH, {"items": []})

def ensure_schema(db):
  if not isinstance(db, dict):
    return {"schemaVersion": SCHEMA_VERSION, "nextId": 1, "updatedAt": utc_now(), "items": []}
  if "schemaVersion" not in db:
    db["schemaVersion"] = SCHEMA_VERSION
  if "items" not in db:
    db["items"] = []
  if "nextId" not in db:
    db["nextId"] = 1
  else:
    try:
      db["nextId"] = int(db["nextId"])
    except (ValueError, TypeError):
      print(f"Warning: nextId in db.json was not an integer, resetting to 1. Value: {db['nextId']}")
      db["nextId"] = 1
  if "updatedAt" not in db:
    db["updatedAt"] = utc_now()
  return db


def process_pending_forever(interval_seconds=2):
  while True:
    try:
      with LOCK:
        pending = load_json(PENDING_PATH, {"items": []})
        if pending.get('items'):
          db = ensure_schema(load_json(DB_PATH, {"schemaVersion": SCHEMA_VERSION, "nextId": 1, "updatedAt": utc_now(), "items": []}))
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
    self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
    self.send_header('Access-Control-Allow-Headers', 'Content-Type')
    self.end_headers()

  def do_OPTIONS(self):
    self._set_headers(HTTPStatus.NO_CONTENT)

  def do_GET(self):
    try:
      parsed = urlparse(self.path)
      if parsed.path == '/api/items':
        with LOCK:
          db = ensure_schema(load_json(DB_PATH, {"schemaVersion": SCHEMA_VERSION, "nextId": 1, "updatedAt": utc_now(), "items": []}))
        self._set_headers()
        self.wfile.write(json.dumps({
          "schemaVersion": db.get("schemaVersion", SCHEMA_VERSION),
          "items": db.get('items', []),
          "updatedAt": db.get('updatedAt')
        }).encode('utf-8'))
        return

      if os.path.exists(CLIENT_DIST):
        if parsed.path == '/' or parsed.path == '':
          self.path = '/index.html'
        
        cwd = os.getcwd()
        os.chdir(CLIENT_DIST)
        try:
          return super().do_GET()
        finally:
          os.chdir(cwd)

      self._set_headers(HTTPStatus.NOT_FOUND)
      self.wfile.write(json.dumps({"error": "Build the client first (npm run build)."}).encode('utf-8'))
    except Exception as e:
      print(f"Error in do_GET: {e}")
      traceback.print_exc()
      self._set_headers(HTTPStatus.INTERNAL_SERVER_ERROR)
      self.wfile.write(json.dumps({"error": "Internal Server Error"}).encode('utf-8'))

  def do_POST(self):
    try:
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
        db = ensure_schema(load_json(DB_PATH, {"schemaVersion": SCHEMA_VERSION, "nextId": 1, "updatedAt": utc_now(), "items": []}))
        # Explicitly ensure nextId is an integer after loading
        db['nextId'] = int(db.get('nextId', 1))

        pending = load_json(PENDING_PATH, {"items": []})
        item_id = str(db['nextId'])
        db['nextId'] += 1
        db['updatedAt'] = utc_now()
        item['id'] = item_id
        pending.setdefault('items', []).append(item)
        print(f"Saving DB with nextId: {db['nextId']}") # Added log
        save_json(DB_PATH, db)
        save_json(PENDING_PATH, pending)

      self._set_headers(HTTPStatus.CREATED)
      print(f"Returning item: {item}") # Added log
      self.wfile.write(json.dumps({"item": item}).encode('utf-8'))
    except Exception as e:
      print(f"Error in do_POST: {e}")
      traceback.print_exc()
      self._set_headers(HTTPStatus.INTERNAL_SERVER_ERROR)
      self.wfile.write(json.dumps({"error": "Internal Server Error"}).encode('utf-8'))

  def do_PUT(self):
    parsed = urlparse(self.path)
    if not parsed.path.startswith('/api/items/'):
      self._set_headers(HTTPStatus.NOT_FOUND)
      self.wfile.write(json.dumps({"error": "Not found"}).encode('utf-8'))
      return

    item_id = parsed.path.split('/api/items/', 1)[1]
    if not item_id:
      self._set_headers(HTTPStatus.BAD_REQUEST)
      self.wfile.write(json.dumps({"error": "Missing id"}).encode('utf-8'))
      return

    content_length = int(self.headers.get('Content-Length', '0'))
    payload = self.rfile.read(content_length).decode('utf-8')
    try:
      data = json.loads(payload) if payload else {}
    except json.JSONDecodeError:
      self._set_headers(HTTPStatus.BAD_REQUEST)
      self.wfile.write(json.dumps({"error": "Invalid JSON"}).encode('utf-8'))
      return

    allowed_fields = {"name", "type", "html", "css", "js"}
    patch = {k: v for k, v in data.items() if k in allowed_fields}
    if not patch:
      self._set_headers(HTTPStatus.BAD_REQUEST)
      self.wfile.write(json.dumps({"error": "No valid fields"}).encode('utf-8'))
      return

    with LOCK:
      db = ensure_schema(load_json(DB_PATH, {"schemaVersion": SCHEMA_VERSION, "nextId": 1, "updatedAt": utc_now(), "items": []}))
      updated = None
      for item in db.get("items", []):
        if str(item.get("id")) == str(item_id):
          item.update({k: str(v) for k, v in patch.items()})
          item["updatedAt"] = utc_now()
          updated = item
          break
      if updated is None:
        self._set_headers(HTTPStatus.NOT_FOUND)
        self.wfile.write(json.dumps({"error": "Item not found"}).encode('utf-8'))
        return
      db["updatedAt"] = utc_now()
      save_json(DB_PATH, db)

    self._set_headers()
    self.wfile.write(json.dumps({"item": updated}).encode('utf-8'))

  def do_DELETE(self):
    parsed = urlparse(self.path)
    if not parsed.path.startswith('/api/items/'):
      self._set_headers(HTTPStatus.NOT_FOUND)
      self.wfile.write(json.dumps({"error": "Not found"}).encode('utf-8'))
      return

    item_id = parsed.path.split('/api/items/', 1)[1]
    if not item_id:
      self._set_headers(HTTPStatus.BAD_REQUEST)
      self.wfile.write(json.dumps({"error": "Missing id"}).encode('utf-8'))
      return

    with LOCK:
      db = ensure_schema(load_json(DB_PATH, {"schemaVersion": SCHEMA_VERSION, "nextId": 1, "updatedAt": utc_now(), "items": []}))
      before = len(db.get("items", []))
      db["items"] = [item for item in db.get("items", []) if str(item.get("id")) != str(item_id)]
      after = len(db["items"])
      if before == after:
        self._set_headers(HTTPStatus.NOT_FOUND)
        self.wfile.write(json.dumps({"error": "Item not found"}).encode('utf-8'))
        return
      db["updatedAt"] = utc_now()
      save_json(DB_PATH, db)

    self._set_headers(HTTPStatus.NO_CONTENT)


def run_server(host='0.0.0.0', port=4177):
  server = HTTPServer((host, port), AlkiHandler)
  print(f"Alki server running on http://{host}:{port}")
  server.serve_forever()


if __name__ == '__main__':
  os.makedirs(DATA_DIR, exist_ok=True)
  _initialize_data_files() # Initialize data files on startup

  thread = threading.Thread(target=process_pending_forever, daemon=True)
  thread.start()
  run_server()
