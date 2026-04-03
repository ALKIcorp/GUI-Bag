import { useState } from 'react';

export default function ItemList({ theme, items, selectedId, onSelect, onUpdateItem }) {
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
    <div className="w-[42%] border-l-[4px] flex flex-col p-2 pt-4 relative" style={{ backgroundColor: theme.panel2, borderLeftColor: theme.stroke }}>
      <div className="flex-1 overflow-y-auto space-y-1.5 pr-2 custom-scroll pb-12">
        {items.map((item) => (
          <div
            key={item.id}
            onClick={() => onSelect(item.id)}
            onDoubleClick={() => handleDoubleClick(item)}
            className="relative cursor-pointer h-9 flex items-center px-3 transition-all duration-75"
            style={{
              backgroundColor: selectedId === item.id ? theme.accent : theme.editorBg,
              color: selectedId === item.id ? theme.panel : theme.mutedText,
              transform: selectedId === item.id ? 'translateX(0.25rem)' : 'translateX(0)',
              boxShadow: selectedId === item.id ? '0 10px 20px rgba(0,0,0,0.22)' : 'none',
              fontWeight: selectedId === item.id ? 900 : 500,
              clipPath: 'polygon(5% 0%, 95% 0%, 100% 50%, 95% 100%, 5% 100%, 0% 50%)'
            }}
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
