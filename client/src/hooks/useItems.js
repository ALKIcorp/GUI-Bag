import { useCallback, useEffect, useMemo, useState } from 'react';
import { INITIAL_DATA } from '../data/initialData.js';

const API_BASE = '/api/items';

export function useItems() {
  const [items, setItems] = useState([]);
  const [selectedId, setSelectedId] = useState(null);
  const [status, setStatus] = useState('idle');
  const [error, setError] = useState(null);

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

  const addItem = useCallback(async (payload) => {
    try {
      const res = await fetch(API_BASE, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
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
  }, []);

  const removeItemLocal = useCallback((id) => {
    setItems((prev) => prev.filter((item) => item.id !== id));
  }, []);

  return {
    items,
    setItems,
    selectedId,
    setSelectedId,
    currentItem,
    status,
    error,
    updateItemLocal,
    addItem,
    removeItemLocal
  };
}
