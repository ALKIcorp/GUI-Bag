import { Save, RefreshCcw } from 'lucide-react';

export default function TopPanel({ isBooting, srcDoc, onSave, onRefresh }) {
  return (
    <div className="flex-[4] bg-[#7d1a2a] border-[8px] border-[#151515] rounded-t-[2rem] relative overflow-hidden flex flex-col">
      <div
        className="absolute inset-0 opacity-10 pointer-events-none"
        style={{ backgroundImage: 'radial-gradient(#000 2px, transparent 0)', backgroundSize: '8px 8px' }}
      ></div>

      {/* Buttons */}
      <div className="absolute top-4 right-4 z-20 flex gap-2">
        <button
          onClick={onSave}
          className="w-8 h-8 bg-green-600 rounded-full flex items-center justify-center border-b-[3px] border-green-900 active:border-b-0 active:translate-y-0.5 shadow-lg text-white"
          title="Save Current Item"
        >
          <Save size={16} />
        </button>
        <button
          onClick={onRefresh}
          className="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center border-b-[3px] border-blue-900 active:border-b-0 active:translate-y-0.5 shadow-lg text-white"
          title="Refresh Display"
        >
          <RefreshCcw size={16} />
        </button>
      </div>

      <div className="flex-1 m-4 sm:m-6 bg-white rounded-lg z-10 overflow-hidden relative border-4 border-[#151515] shadow-2xl">
        {isBooting ? (
          <div className="w-full h-full bg-black flex items-center justify-center">
            <div className="text-white font-mono text-[9px] tracking-[0.5em] animate-pulse uppercase italic">LINKING...</div>
          </div>
        ) : (
          <iframe srcDoc={srcDoc} title="preview" sandbox="allow-scripts" className="w-full h-full border-none" />
        )}
      </div>
    </div>
  );
}
