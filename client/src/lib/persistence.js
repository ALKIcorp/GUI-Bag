const API_BASE = '/api/items';
const NATIVE_HANDLER = 'guiBagBridge';

function hasNativeBridge() {
  return Boolean(window.webkit?.messageHandlers?.[NATIVE_HANDLER]);
}

function createNativeClient() {
  let nextRequestId = 1;
  const pending = new Map();

  window.__guiBagNativeReceive = (encodedResponse) => {
    try {
      const json = window.atob(encodedResponse);
      const message = JSON.parse(json);
      const request = pending.get(message.requestId);
      if (!request) return;
      pending.delete(message.requestId);

      if (message.ok) {
        request.resolve(message.payload);
      } else {
        request.reject(new Error(message.error?.message || 'Native request failed'));
      }
    } catch (error) {
      console.error('Failed to decode native response', error);
    }
  };

  const send = (action, payload = null) => new Promise((resolve, reject) => {
    const requestId = nextRequestId++;
    pending.set(requestId, { resolve, reject });

    window.webkit.messageHandlers[NATIVE_HANDLER].postMessage({
      requestId,
      action,
      payload
    });
  });

  return {
    async listItems() {
      return send('listItems');
    },
    async createItem(payload) {
      return send('createItem', payload);
    },
    async updateItem(id, patch) {
      return send('updateItem', { id, patch });
    },
    async deleteItem(id) {
      return send('deleteItem', { id });
    }
  };
}

function createHttpClient() {
  return {
    async listItems() {
      const res = await fetch(API_BASE);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json();
    },
    async createItem(payload) {
      const res = await fetch(API_BASE, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json();
    },
    async updateItem(id, patch) {
      const res = await fetch(`${API_BASE}/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(patch)
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json();
    },
    async deleteItem(id) {
      const res = await fetch(`${API_BASE}/${id}`, { method: 'DELETE' });
      if (!res.ok && res.status !== 204) throw new Error(`HTTP ${res.status}`);
      return { success: true };
    }
  };
}

export function createPersistenceClient() {
  if (hasNativeBridge()) {
    return createNativeClient();
  }

  return createHttpClient();
}
