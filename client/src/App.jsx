import { useEffect, useMemo, useState } from 'react';
import ConsoleWindow from './components/ConsoleWindow.jsx';
import AddItemModal from './components/AddItemModal.jsx'; // Import the new modal
import { DEFAULT_THEME, THEME_PRESETS, THEME_STORAGE_KEY } from './data/themes.js';
import { useBoot } from './hooks/useBoot.js';
import { useResize } from './hooks/useResize.js';
import { useItems } from './hooks/useItems.js';

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
    if (!currentItem) return '';

    return `
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            body { display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: ${theme.previewBg}; color: ${theme.text}; font-family: sans-serif; overflow: hidden; }
            ${currentItem.css}
          </style>
        </head>
        <body>
          ${currentItem.html}
          <script>${currentItem.js}<\/script>
        </body>
      </html>
    `;
  }, [currentItem, refreshKey, theme.previewBg, theme.text]);

  useEffect(() => {
    window.localStorage.setItem(THEME_STORAGE_KEY, theme.name);
  }, [theme]);

  const handleUpdateCode = (type, value) => {
    if (!selectedId) return;
    updateItem(selectedId, { [type]: value });
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
    const removed = await removeItem(selectedId);
    if (!removed) return;
    const next = items.find((item) => item.id !== selectedId);
    if (next) setSelectedId(next.id);
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-6 overflow-hidden" style={{ backgroundColor: theme.appBg }}>
      <ConsoleWindow
        size={size}
        onResizeStart={startResize}
        isBooting={isBooting}
        srcDoc={srcDoc}
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
