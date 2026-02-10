import { useMemo, useState } from 'react';
import ConsoleWindow from './components/ConsoleWindow.jsx';
import AddItemModal from './components/AddItemModal.jsx'; // Import the new modal
import { useBoot } from './hooks/useBoot.js';
import { useResize } from './hooks/useResize.js';
import { useItems } from './hooks/useItems.js';

export default function App() {
  const [activeTab, setActiveTab] = useState('html');
  const [showAddItemModal, setShowAddItemModal] = useState(false); // State for modal visibility
  const [refreshKey, setRefreshKey] = useState(0); // State to force iframe refresh
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

    // If 'all' code is present, use only that.
    if (currentItem.all && currentItem.all.trim() !== '') {
      return currentItem.all;
    }

    // Otherwise, combine html, css, and js.
    return `
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            body { display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #1a1a1a; font-family: sans-serif; overflow: hidden; }
            ${currentItem.css}
          </style>
        </head>
        <body>
          ${currentItem.html}
          <script>${currentItem.js}<\/script>
        </body>
      </html>
    `;
  }, [currentItem, refreshKey]); // Add refreshKey as a dependency

  const handleUpdateCode = (type, value) => {
    if (!selectedId) return;
    updateItem(selectedId, { [type]: value });
  };

  const handleSaveItem = () => {
    if (!selectedId || !currentItem) return;
    updateItem(selectedId, currentItem); // Persist currentItem's state
    console.log('Item saved:', currentItem.name);
  };

  const handleRefreshDisplay = () => {
    setRefreshKey(prevKey => prevKey + 1); // Increment key to force re-render of iframe
    console.log('Display refreshed.');
  };

  // Modified handleAddItem to accept a payload directly from the modal
  const handleAddItem = async (itemName) => {
    console.log('handleAddItem called with itemName:', itemName);
    const item = await addItem({
      name: itemName,
      type: 'UI',
      html: '',
      css: '',
      js: '',
      all: ''
    });

    if (!item) {
      console.error('Failed to add item.');
      return;
    }

    console.log('Item added successfully:', item);
    setShowAddItemModal(false); // Close modal on successful addition
  };

  const handleRemoveItem = async () => {
    if (!selectedId || items.length <= 1) return;
    const removed = await removeItem(selectedId);
    if (!removed) return;
    const next = items.find((item) => item.id !== selectedId);
    if (next) setSelectedId(next.id);
  };

  return (
    <div className="min-h-screen bg-[#050505] flex items-center justify-center p-6 overflow-hidden">
      <ConsoleWindow
        size={size}
        onResizeStart={startResize}
        isBooting={isBooting}
        srcDoc={srcDoc}
        activeTab={activeTab}
        onChangeTab={setActiveTab}
        currentItem={currentItem}
        items={items}
        selectedId={selectedId}
        onSelectItem={setSelectedId}
        onUpdateCode={handleUpdateCode}
        onAddItem={() => setShowAddItemModal(true)} // Open modal when add is clicked
        onRemoveItem={handleRemoveItem}
        onUpdateItem={updateItem}
        onSave={handleSaveItem} // Pass save handler
        onRefreshDisplay={handleRefreshDisplay} // Pass refresh handler
      />
      {/* Render the AddItemModal */}
      <AddItemModal
        isOpen={showAddItemModal}
        onClose={() => setShowAddItemModal(false)}
        onAddItem={handleAddItem}
      />
    </div>
  );
}
