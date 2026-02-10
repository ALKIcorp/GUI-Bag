import React from 'react';
import { Save, RefreshCcw } from 'lucide-react';

export default function SaveRefreshButtons({ onSave, onRefresh }) {
  return (
    <div className="flex gap-2 p-2"> {/* Added padding for some space */}
      <button
        onClick={onSave}
        className="w-12 h-6 bg-green-600 rounded-md flex items-center justify-center border-b-[3px] border-green-900 active:border-b-0 active:translate-y-0.5 shadow-lg text-white"
        title="Save Current Item"
      >
        <Save size={16} />
      </button>
      <button
        onClick={onRefresh}
        className="w-12 h-6 bg-blue-600 rounded-md flex items-center justify-center border-b-[3px] border-blue-900 active:border-b-0 active:translate-y-0.5 shadow-lg text-white"
        title="Refresh Display"
      >
        <RefreshCcw size={16} />
      </button>
    </div>
  );
}
