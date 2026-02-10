import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { INITIAL_DATA } from '../data/initialData.js';
import { generateDefaultName } from '../utils/nameGenerator.js';

const API_BASE = '/api/items';

export function useItems() {
  const [items, setItems] = useState([]);
  const [selectedId, setSelectedId] = useState(null);
  const [status, setStatus] = useState('idle');
  const [error, setError] = useState(null);
  const updateQueueRef = useRef({});

  const currentItem = useMemo(() => {
    if (!items.length) return null;
    return items.find((item) => item.id === selectedId) || items[0];
  }, [items, selectedId]);

  useEffect(() => {
    let mounted = true;

    const load = async () => {
      setStatus('loading');
      try {
        const res = await fetch(API_BASE);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();
        if (!mounted) return;
        const nextItems = (data?.items?.length ? data.items : INITIAL_DATA).map(item => ({
          ...item,
          all: item.all ?? '' // Ensure 'all' property exists
        }));
        setItems(nextItems);
        setSelectedId(nextItems[0]?.id ?? null);
        setStatus('ready');
      } catch (err) {
        if (!mounted) return;
        setItems(INITIAL_DATA);
        setSelectedId(INITIAL_DATA[0]?.id ?? null);
        setStatus('offline');
        setError(err);
      }
    };

    load();

    return () => {
      mounted = false;
    };
  }, []);

  const updateItemLocal = useCallback((id, patch) => {
    setItems((prev) => prev.map((item) => (item.id === id ? { ...item, ...patch } : item)));
  }, []);

  const flushUpdate = useCallback(async (id) => {
    const entry = updateQueueRef.current[id];
    if (!entry) return;
    clearTimeout(entry.timer);
    updateQueueRef.current[id] = null;

    try {
      await fetch(`${API_BASE}/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(entry.patch)
      });
    } catch (err) {
      setError(err);
    }
  }, []);

  const updateItem = useCallback((id, patch) => {
    if (!id) return;
    updateItemLocal(id, patch);

    const existing = updateQueueRef.current[id] || { patch: {}, timer: null };
    existing.patch = { ...existing.patch, ...patch };
    clearTimeout(existing.timer);
    existing.timer = setTimeout(() => flushUpdate(id), 400);
    updateQueueRef.current[id] = existing;
  }, [flushUpdate, updateItemLocal]);

  const addItem = useCallback(async (payload) => {
    const itemToAdd = { all: '', ...payload }; // Ensure 'all' is always present
    if (!itemToAdd.name) {
      itemToAdd.name = generateDefaultName(items);
    }

    try {
      const res = await fetch(API_BASE, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(itemToAdd)
      });

      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      if (data?.item) {
        setItems((prev) => [...prev, data.item]);
        setSelectedId(data.item.id);
        return data.item;
      }
    } catch (err) {
      setError(err);
    }

    return null;
  }, [items]);

  const removeItemLocal = useCallback((id) => {
    setItems((prev) => prev.filter((item) => item.id !== id));
  }, []);

  const removeItem = useCallback(async (id) => {
    if (!id) return false;
    try {
      const res = await fetch(`${API_BASE}/${id}`, { method: 'DELETE' });
      if (!res.ok && res.status !== 204) throw new Error(`HTTP ${res.status}`);
      removeItemLocal(id);
      return true;
    } catch (err) {
      setError(err);
      return false;
    }
  }, [removeItemLocal]);

  return {
    items,
    setItems,
    selectedId,
    setSelectedId,
    currentItem,
    status,
    error,
    updateItemLocal,
    updateItem,
    addItem,
    removeItemLocal,
    removeItem
  };
}
