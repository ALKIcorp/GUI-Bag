import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { INITIAL_DATA } from '../data/initialData.js';
import { generateDefaultName } from '../utils/nameGenerator.js';
import { createPersistenceClient } from '../lib/persistence.js';

const persistence = createPersistenceClient();

export function useItems() {
  const [items, setItems] = useState([]);
  const [selectedId, setSelectedId] = useState(null);
  const [status, setStatus] = useState('idle');
  const [error, setError] = useState(null);
  const itemsRef = useRef([]);
  const updateQueueRef = useRef({});

  useEffect(() => {
    itemsRef.current = items;
  }, [items]);

  const currentItem = useMemo(() => {
    if (!items.length) return null;
    return items.find((item) => item.id === selectedId) || items[0];
  }, [items, selectedId]);

  useEffect(() => {
    let mounted = true;

    const load = async () => {
      setStatus('loading');
      try {
        const data = await persistence.listItems();
        if (!mounted) return;
        const nextItems = data?.items?.length ? data.items : INITIAL_DATA;
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
      const response = await persistence.updateItem(id, entry.patch);
      if (response?.item) {
        updateItemLocal(id, response.item);
      }
    } catch (err) {
      setError(err);
    }
  }, [updateItemLocal]);

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
    const itemToAdd = { ...payload };
    if (!itemToAdd.name) {
      itemToAdd.name = generateDefaultName(itemsRef.current);
    }

    try {
      const data = await persistence.createItem(itemToAdd);
      if (data?.item) {
        setItems((prev) => {
          if (prev.some((item) => item.id === data.item.id)) {
            return prev.map((item) => (item.id === data.item.id ? data.item : item));
          }

          return [...prev, data.item];
        });
        setSelectedId(data.item.id);
        return data.item;
      }
    } catch (err) {
      setError(err);
    }

    return null;
  }, []);

  const removeItemLocal = useCallback((id) => {
    setItems((prev) => prev.filter((item) => item.id !== id));
  }, []);

  const removeItem = useCallback(async (id) => {
    if (!id) return false;
    try {
      await persistence.deleteItem(id);
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
