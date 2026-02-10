import { useState } from 'react';

export default function ItemList({ items, selectedId, onSelect, onUpdateItem }) {
  const [editingItemId, setEditingItemId] = useState(null);
  const [newName, setNewName] = useState('');

  const handleDoubleClick = (item) => {
    setEditingItemId(item.id);
    setNewName(item.name);
  };

  const handleBlur = async (item) => {
    if (newName && newName !== item.name) {
      await onUpdateItem(item.id, { name: newName });
    }
    setEditingItemId(null);
    setNewName('');
  };

  const handleKeyDown = async (e, item) => {
    if (e.key === 'Enter') {
      e.target.blur();
    }
  };

  return (
    <div className="w-[42%] bg-[#1a1a1a] border-l-[4px] border-[#151515] flex flex-col p-2 pt-4 relative">
      <div className="flex-1 overflow-y-auto space-y-1.5 pr-2 custom-scroll pb-12">
        {items.map((item) => (
          <div
            key={item.id}
            onClick={() => onSelect(item.id)}
            onDoubleClick={() => handleDoubleClick(item)}
            className={`relative cursor-pointer h-9 flex items-center px-3 transition-all duration-75
              ${selectedId === item.id ? 'bg-white text-black translate-x-1 shadow-md font-black' : 'bg-[#2a2a2a] text-gray-500'}`}
            style={{ clipPath: 'polygon(5% 0%, 95% 0%, 100% 50%, 95% 100%, 5% 100%, 0% 50%)' }}
          >
            {editingItemId === item.id ? (
              <input
                type="text"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                onBlur={() => handleBlur(item)}
                onKeyDown={(e) => handleKeyDown(e, item)}
                className="bg-transparent border-none outline-none w-full text-[8px] uppercase italic truncate text-center tracking-tighter"
                autoFocus
              />
            ) : (
              <span className="text-[8px] uppercase italic truncate w-full text-center tracking-tighter">{item.name}</span>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
