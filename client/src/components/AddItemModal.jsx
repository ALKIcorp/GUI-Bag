import React, { useState } from 'react';
import { Plus, X, PackagePlus } from 'lucide-react';

const AddItemModal = ({ isOpen, onClose, onAddItem }) => {
  const [itemName, setItemName] = useState('');

  // Styles based on the "Alki" aesthetic in your image
  const colors = {
    bgDark: '#0f0f0f',
    panelRed: '#a3333d',
    cardDark: '#1a1a1a',
    textMuted: '#888',
    textLight: '#efefef',
    accentGreen: '#4ade80',
    accentRed: '#ef4444'
  };

  if (!isOpen) {
    return null; // Don't render anything if not open
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 font-sans uppercase tracking-wider">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/80 backdrop-blur-sm" onClick={onClose} />

      {/* Modal Container */}
      <div className="relative w-full max-w-md bg-[#a3333d] p-1 rounded-[2.5rem] shadow-2xl border border-white/5 overflow-hidden">
        <div className="bg-[#121212] rounded-[2.3rem] overflow-hidden flex flex-col">
          
          {/* Header Area */}
          <div className="p-6 pb-2 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-[#a3333d]/20 rounded-lg flex items-center justify-center border border-[#a3333d]/30">
                <PackagePlus size={20} className="text-[#a3333d]" />
              </div>
              <h2 className="text-white text-lg font-bold italic tracking-tighter">
                Add New Item
              </h2>
            </div>
            <button 
              onClick={onClose}
              className="text-white/30 hover:text-white transition-colors"
            >
              <X size={24} />
            </button>
          </div>

          {/* Input Section */}
          <div className="px-6 py-4">
            <label className="text-[10px] text-[#a3333d] font-black mb-2 block ml-1">
              Item Designation
            </label>
            <div className="bg-[#0a0a0a] border-2 border-[#1f1f1f] rounded-2xl p-4 focus-within:border-[#a3333d] transition-all">
              <input 
                autoFocus
                type="text"
                placeholder="ENTER NAME..."
                value={itemName}
                onChange={(e) => setItemName(e.target.value)}
                className="bg-transparent w-full text-white outline-none font-mono text-sm placeholder:text-white/10"
              />
            </div>
          </div>

          {/* Action Buttons - Matching the angled style in your image */}
          <div className="p-6 pt-2 flex flex-col gap-3">
            
            {/* Add Button */}
            <button 
              className="relative group overflow-hidden"
              onClick={() => {
                console.log('Confirm Addition clicked, itemName:', itemName);
                onAddItem(itemName);
                setItemName(''); // Clear input after adding
              }}
            >
              <div className="bg-white text-black py-4 px-6 font-black italic flex justify-center items-center gap-2 transition-transform active:scale-95"
                   style={{ clipPath: 'polygon(5% 0%, 100% 0%, 95% 100%, 0% 100%)' }}>
                CONFIRM ADDITION
              </div>
            </button>

            {/* Cancel Button */}
            <button 
              className="relative group overflow-hidden"
              onClick={onClose}
            >
              <div className="bg-[#1a1a1a] text-[#444] py-3 px-6 font-bold italic flex justify-center items-center transition-colors hover:text-[#a3333d]"
                   style={{ clipPath: 'polygon(5% 0%, 100% 0%, 95% 100%, 0% 100%)' }}>
                CANCEL
              </div>
            </button>

          </div>

          {/* Footer Decoration */}
          <div className="bg-[#a3333d] h-2 w-full mt-2 opacity-50" />
        </div>
      </div>
    </div>
  );
};

export default AddItemModal;