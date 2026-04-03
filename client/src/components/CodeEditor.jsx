import { useState } from 'react';
import { ChevronDown, ChevronRight, Code2, Braces, Terminal } from 'lucide-react';

const TABS = [
  { id: 'html', Icon: Code2, label: 'HTML' },
  { id: 'css', Icon: Braces, label: 'CSS' },
  { id: 'js', Icon: Terminal, label: 'JS' },
  { id: 'all', Icon: Code2, label: 'ALL' }
];

const ALL_SECTIONS = [
  {
    id: 'html',
    label: 'HTML',
    accent: 'text-pink-400',
    placeholder: '<!-- html goes here... -->'
  },
  {
    id: 'css',
    label: 'CSS',
    accent: 'text-cyan-400',
    placeholder: '/* css goes here... */'
  },
  {
    id: 'js',
    label: 'JavaScript',
    accent: 'text-amber-300',
    placeholder: '// javascript goes here...'
  }
];

function SingleEditor({ activeTab, value, onChange }) {
  return (
    <textarea
      className="flex-1 bg-transparent p-3 font-mono text-[10px] outline-none resize-none text-pink-400 placeholder-pink-950 custom-scroll leading-relaxed"
      value={value ?? ''}
      onChange={(e) => onChange(e.target.value)}
      spellCheck="false"
      placeholder={`// ${activeTab} goes here...`}
    />
  );
}

function AllSectionsEditor({ currentItem, onChangeCode }) {
  const [collapsedSections, setCollapsedSections] = useState({});

  const toggleSection = (sectionId) => {
    setCollapsedSections((prev) => ({
      ...prev,
      [sectionId]: !prev[sectionId]
    }));
  };

  return (
    <div className="flex-1 overflow-y-auto custom-scroll bg-[#090909] p-3 flex flex-col gap-3">
      {ALL_SECTIONS.map((section) => {
        const isCollapsed = Boolean(collapsedSections[section.id]);
        const value = currentItem?.[section.id] ?? '';
        const ToggleIcon = isCollapsed ? ChevronRight : ChevronDown;

        return (
          <section
            key={section.id}
            className="rounded-xl border border-white/10 bg-[#111111] shadow-[inset_0_1px_0_rgba(255,255,255,0.04)] overflow-hidden"
          >
            <button
              type="button"
              onClick={() => toggleSection(section.id)}
              className="w-full px-3 py-2 bg-[#1a1a1a] border-b border-black/70 flex items-center justify-between text-left"
            >
              <span className="flex items-center gap-2">
                <ToggleIcon size={12} className="text-white/70" />
                <span className={`text-[9px] font-black tracking-[0.25em] uppercase ${section.accent}`}>
                  {section.label}
                </span>
              </span>
              <span className="text-[8px] font-bold uppercase text-white/35">
                {isCollapsed ? 'Expand' : 'Minimize'}
              </span>
            </button>

            {!isCollapsed ? (
              <textarea
                className={`w-full min-h-[140px] bg-transparent p-3 font-mono text-[10px] outline-none resize-y ${section.accent} placeholder:text-white/15 custom-scroll leading-relaxed`}
                value={value}
                onChange={(e) => onChangeCode(section.id, e.target.value)}
                spellCheck="false"
                placeholder={section.placeholder}
              />
            ) : null}
          </section>
        );
      })}
    </div>
  );
}

export default function CodeEditor({ activeTab, onChangeTab, value, onChange, currentItem, onChangeCode }) {
  return (
    <div className="w-[58%] p-3 flex flex-col gap-3">
      <div className="flex justify-center gap-2">
        {TABS.map(({ id, Icon, label }) => (
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
      </div>

      <div className="flex-1 bg-[#0a0a0a] rounded-xl border-4 border-[#151515] flex flex-col shadow-inner overflow-hidden">
        <div className="px-3 py-1 bg-[#1a1a1a] border-b-2 border-[#000] flex justify-between items-center">
          <span className="text-[8px] font-black italic tracking-widest text-pink-500/80">{activeTab}.alki</span>
        </div>
        {activeTab === 'all' ? (
          <AllSectionsEditor currentItem={currentItem} onChangeCode={onChangeCode} />
        ) : (
          <SingleEditor activeTab={activeTab} value={value} onChange={onChange} />
        )}
      </div>
    </div>
  );
}
