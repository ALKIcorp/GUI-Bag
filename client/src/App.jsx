import { useMemo, useState } from 'react';
import ConsoleWindow from './components/ConsoleWindow.jsx';
import { useBoot } from './hooks/useBoot.js';
import { useResize } from './hooks/useResize.js';
import { useItems } from './hooks/useItems.js';

export default function App() {
  const [activeTab, setActiveTab] = useState('html');
  const isBooting = useBoot(600);
  const { size, startResize } = useResize();
  const {
    items,
    selectedId,
    setSelectedId,
    currentItem,
    updateItemLocal,
    addItem,
    removeItemLocal
  } = useItems();

  const srcDoc = useMemo(() => {
    if (!currentItem) return '';
    return `
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            body { display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #fff; font-family: sans-serif; overflow: hidden; }
            ${currentItem.css}
          </style>
        </head>
        <body>
          ${currentItem.html}
          <script>${currentItem.js}<\/script>
        </body>
      </html>
    `;
  }, [currentItem]);

  const handleUpdateCode = (type, value) => {
    if (!selectedId) return;
    updateItemLocal(selectedId, { [type]: value });
  };

  const handleAddItem = async () => {
    const item = await addItem({
      name: 'NEW_CODE',
      type: 'UI',
      html: '',
      css: '',
      js: ''
    });

    if (!item) return;
  };

  const handleRemoveItem = () => {
    if (!selectedId || items.length <= 1) return;
    removeItemLocal(selectedId);
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
        onAddItem={handleAddItem}
        onRemoveItem={handleRemoveItem}
      />
    </div>
  );
}
