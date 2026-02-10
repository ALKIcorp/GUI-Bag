import { Code2, Braces, Terminal, RefreshCcw } from 'lucide-react';

const TABS = [
  { id: 'html', Icon: Code2, label: 'HTML' },
  { id: 'css', Icon: Braces, label: 'CSS' },
  { id: 'js', Icon: Terminal, label: 'JS' },
  { id: 'all', Icon: Code2, label: 'ALL' } // New 'All' tab
];

export default function CodeEditor({ activeTab, onChangeTab, value, onChange, onRefreshPreview }) {
  return (
    <div className="w-[58%] p-3 flex flex-col gap-3">
      <div className="flex justify-center gap-2 relative"> {/* Add relative for absolute positioning */}
        {TABS.map(({ id, Icon, label }) => ( // Destructure label
          <button
            key={id}
            onClick={() => onChangeTab(id)}
            className={`flex flex-col items-center justify-center w-11 h-11 rounded-xl border-2 transition-all shadow-lg
              ${activeTab === id ? 'bg-white text-[#a91d3a] border-white scale-105' : 'bg-[#7d1a2a]/40 text-white border-white/10 hover:bg-[#7d1a2a]/60'}`}
          >
            <Icon size={18} />
            <span className="text-[6px] font-black mt-0.5 uppercase">{label}</span> {/* Use label */}
          </button>
        ))}
        {/* Refresh Button for Code Editor */}
        <button
          onClick={onRefreshPreview}
          className="absolute right-0 top-1/2 -translate-y-1/2 w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center border-b-[3px] border-blue-900 active:border-b-0 active:translate-y-0.5 shadow-lg text-white"
          title="Refresh Code Preview"
        >
          <RefreshCcw size={16} />
        </button>
      </div>

      <div className="flex-1 bg-[#0a0a0a] rounded-xl border-4 border-[#151515] flex flex-col shadow-inner overflow-hidden">
        <div className="px-3 py-1 bg-[#1a1a1a] border-b-2 border-[#000] flex justify-between items-center">
          <span className="text-[8px] font-black italic tracking-widest text-pink-500/80">{activeTab}.alki</span>
        </div>
        <textarea
          className="flex-1 bg-transparent p-3 font-mono text-[10px] outline-none resize-none text-pink-400 placeholder-pink-950 custom-scroll leading-relaxed"
          value={value ?? ''}
          onChange={(e) => onChange(e.target.value)}
          spellCheck="false"
          placeholder={`// ${activeTab} goes here...`}
        />
      </div>
    </div>
  );
}
