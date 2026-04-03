import { useEffect, useMemo, useState } from 'react';
import ConsoleWindow from './components/ConsoleWindow.jsx';
import AddItemModal from './components/AddItemModal.jsx'; // Import the new modal
import { DEFAULT_THEME, THEME_PRESETS, THEME_STORAGE_KEY } from './data/themes.js';
import { useBoot } from './hooks/useBoot.js';
import { useResize } from './hooks/useResize.js';
import { useItems } from './hooks/useItems.js';

const FENCED_BLOCK_RE = /^\s*```(?:[a-z0-9_-]+)?\s*\n?([\s\S]*?)\n?```\s*$/i;
const SCRIPT_BLOCK_RE = /^\s*<script\b[^>]*>([\s\S]*?)<\/script>\s*$/i;
const STYLE_BLOCK_RE = /^\s*<style\b[^>]*>([\s\S]*?)<\/style>\s*$/i;
const FULL_DOCUMENT_RE = /<!doctype html|<html[\s>]/i;

function unwrapCodeFence(value) {
  const match = value.match(FENCED_BLOCK_RE);
  return match ? match[1] : value;
}

function normalizeCodeInput(type, value) {
  const unfenced = unwrapCodeFence(value ?? '');

  if (type === 'js') {
    const match = unfenced.match(SCRIPT_BLOCK_RE);
    return match ? match[1].trim() : unfenced;
  }

  if (type === 'css') {
    const match = unfenced.match(STYLE_BLOCK_RE);
    return match ? match[1].trim() : unfenced;
  }

  return unfenced;
}

function escapeInlineScript(value) {
  return value.replace(/<\/script/gi, '<\\/script');
}

function injectBeforeClosingTag(document, tagName, snippet) {
  const closingTag = new RegExp(`</${tagName}>`, 'i');
  return closingTag.test(document)
    ? document.replace(closingTag, `${snippet}</${tagName}>`)
    : `${document}${snippet}`;
}

function buildPreviewDocument(item, theme) {
  if (!item) return '';

  const html = normalizeCodeInput('html', item.html);
  const css = normalizeCodeInput('css', item.css);
  const js = normalizeCodeInput('js', item.js);
  const diagnosticsScript = `
    window.addEventListener('error', function (event) {
      window.parent.postMessage({
        source: 'gui-bag-preview',
        type: 'error',
        message: event.message || 'Preview error'
      }, '*');
    });

    window.addEventListener('unhandledrejection', function (event) {
      var reason = event.reason;
      var message = typeof reason === 'string' ? reason : reason?.message || 'Unhandled promise rejection';
      window.parent.postMessage({
        source: 'gui-bag-preview',
        type: 'error',
        message: message
      }, '*');
    });

    window.addEventListener('load', function () {
      window.parent.postMessage({
        source: 'gui-bag-preview',
        type: 'ready'
      }, '*');
    });
  `;
  const sharedStyles = `
    <style>
      body {
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        margin: 0;
        background: ${theme.previewBg};
        color: ${theme.text};
        font-family: sans-serif;
        overflow: hidden;
      }
      ${css}
    </style>
  `;
  const scripts = `
    <script>${escapeInlineScript(diagnosticsScript)}<\/script>
    <script>${escapeInlineScript(js)}<\/script>
  `;

  if (FULL_DOCUMENT_RE.test(html)) {
    const withStyles = injectBeforeClosingTag(html, 'head', sharedStyles);
    return injectBeforeClosingTag(withStyles, 'body', scripts);
  }

  return `
    <!DOCTYPE html>
    <html>
      <head>
        ${sharedStyles}
      </head>
      <body>
        ${html}
        ${scripts}
      </body>
    </html>
  `;
}

function getInitialTheme() {
  if (typeof window === 'undefined') return DEFAULT_THEME;

  const savedThemeName = window.localStorage.getItem(THEME_STORAGE_KEY);
  return THEME_PRESETS.find((theme) => theme.name === savedThemeName) ?? DEFAULT_THEME;
}

export default function App() {
  const [activeTab, setActiveTab] = useState('html');
  const [showAddItemModal, setShowAddItemModal] = useState(false);
  const [refreshKey, setRefreshKey] = useState(0);
  const [theme, setTheme] = useState(getInitialTheme);
  const [previewError, setPreviewError] = useState(null);
  const isBooting = useBoot(600);
  const { size, startResize } = useResize();
  const {
    items,
    selectedId,
    setSelectedId,
    currentItem,
    updateItem,
    addItem,
    removeItem
  } = useItems();

  const srcDoc = useMemo(() => {
    return buildPreviewDocument(currentItem, theme);
  }, [currentItem, refreshKey, theme.previewBg, theme.text]);

  useEffect(() => {
    window.localStorage.setItem(THEME_STORAGE_KEY, theme.name);
  }, [theme]);

  useEffect(() => {
    setPreviewError(null);
  }, [srcDoc]);

  useEffect(() => {
    const handleMessage = (event) => {
      if (event.data?.source !== 'gui-bag-preview') return;

      if (event.data.type === 'error') {
        setPreviewError(event.data.message || 'Preview error');
        return;
      }

      if (event.data.type === 'ready') {
        setPreviewError(null);
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  const handleUpdateCode = (type, value) => {
    if (!selectedId) return;
    updateItem(selectedId, { [type]: normalizeCodeInput(type, value) });
  };

  const handleSaveItem = () => {
    if (!selectedId || !currentItem) return;
    updateItem(selectedId, currentItem);
    console.log('Item saved:', currentItem.name);
  };

  const handleRefreshDisplay = () => {
    setRefreshKey(prevKey => prevKey + 1);
    console.log('Display refreshed.');
  };

  const handleAddItem = async (itemName) => {
    console.log('handleAddItem called with itemName:', itemName);
    const item = await addItem({
      name: itemName,
      type: 'UI',
      html: '',
      css: '',
      js: ''
    });

    if (!item) {
      console.error('Failed to add item.');
      return;
    }

    console.log('Item added successfully:', item);
    setShowAddItemModal(false);
  };

  const handleRemoveItem = async () => {
    if (!selectedId || items.length <= 1) return;
    const removedIndex = items.findIndex((item) => item.id === selectedId);
    const removed = await removeItem(selectedId);
    if (!removed) return;

    const remainingItems = items.filter((item) => item.id !== selectedId);
    const next = remainingItems[removedIndex] ?? remainingItems[removedIndex - 1] ?? remainingItems[0];
    if (next) setSelectedId(next.id);
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-6 overflow-hidden" style={{ backgroundColor: theme.appBg }}>
      <ConsoleWindow
        size={size}
        onResizeStart={startResize}
        isBooting={isBooting}
        srcDoc={srcDoc}
        previewError={previewError}
        theme={theme}
        themePresets={THEME_PRESETS}
        onSelectTheme={setTheme}
        activeTab={activeTab}
        onChangeTab={setActiveTab}
        currentItem={currentItem}
        items={items}
        selectedId={selectedId}
        onSelectItem={setSelectedId}
        onUpdateCode={handleUpdateCode}
        onAddItem={() => setShowAddItemModal(true)}
        onRemoveItem={handleRemoveItem}
        onUpdateItem={updateItem}
        onSave={handleSaveItem}
        onRefreshDisplay={handleRefreshDisplay}
      />
      <AddItemModal
        isOpen={showAddItemModal}
        onClose={() => setShowAddItemModal(false)}
        onAddItem={handleAddItem}
      />
    </div>
  );
}
