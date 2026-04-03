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

function SingleEditor({ activeTab, value, onChange, theme }) {
  return (
    <textarea
      className="flex-1 bg-transparent p-3 font-mono text-[10px] outline-none resize-none custom-scroll leading-relaxed"
      style={{ color: theme.accent2 }}
      value={value ?? ''}
      onChange={(e) => onChange(e.target.value)}
      spellCheck="false"
      placeholder={`// ${activeTab} goes here...`}
    />
  );
}

function AllSectionsEditor({ currentItem, onChangeCode, theme }) {
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
            className="rounded-xl border shadow-[inset_0_1px_0_rgba(255,255,255,0.04)] overflow-hidden"
            style={{ borderColor: `${theme.text}1A`, backgroundColor: theme.appBg }}
          >
            <button
              type="button"
              onClick={() => toggleSection(section.id)}
              className="w-full px-3 py-2 border-b flex items-center justify-between text-left"
              style={{ backgroundColor: theme.panel2, borderBottomColor: `${theme.appBg}B3` }}
            >
              <span className="flex items-center gap-2">
                <ToggleIcon size={12} style={{ color: theme.mutedText }} />
                <span className="text-[9px] font-black tracking-[0.25em] uppercase" style={{ color: section.id === 'html' ? theme.accent2 : section.id === 'css' ? theme.accent : theme.text }}>
                  {section.label}
                </span>
              </span>
              <span className="text-[8px] font-bold uppercase" style={{ color: `${theme.text}59` }}>
                {isCollapsed ? 'Expand' : 'Minimize'}
              </span>
            </button>

            {!isCollapsed ? (
              <textarea
                className="w-full min-h-[140px] bg-transparent p-3 font-mono text-[10px] outline-none resize-y custom-scroll leading-relaxed"
                style={{ color: section.id === 'html' ? theme.accent2 : section.id === 'css' ? theme.accent : theme.text }}
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

export default function CodeEditor({ theme, activeTab, onChangeTab, value, onChange, currentItem, onChangeCode }) {
  return (
    <div className="w-[58%] p-3 flex flex-col gap-3">
      <div className="flex justify-center gap-2">
        {TABS.map(({ id, Icon, label }) => (
          <button
            key={id}
            onClick={() => onChangeTab(id)}
            className="flex flex-col items-center justify-center w-11 h-11 rounded-xl border-2 transition-all shadow-lg"
            style={
              activeTab === id
                ? {
                    backgroundColor: theme.accent,
                    color: theme.panel,
                    borderColor: theme.accent,
                    transform: 'scale(1.05)'
                  }
                : {
                    backgroundColor: `${theme.panel2}A6`,
                    color: theme.text,
                    borderColor: `${theme.text}1A`
                  }
            }
          >
            <Icon size={18} />
            <span className="text-[6px] font-black mt-0.5 uppercase">{label}</span>
          </button>
        ))}
      </div>

      <div
        className="flex-1 rounded-xl border-4 flex flex-col shadow-inner overflow-hidden"
        style={{ backgroundColor: theme.editorBg, borderColor: theme.stroke }}
      >
        <div
          className="px-3 py-1 border-b-2 flex justify-between items-center"
          style={{ backgroundColor: theme.panel2, borderBottomColor: theme.appBg }}
        >
          <span className="text-[8px] font-black italic tracking-widest" style={{ color: theme.accent2 }}>
            {activeTab}.alki
          </span>
        </div>
        {activeTab === 'all' ? (
          <AllSectionsEditor currentItem={currentItem} onChangeCode={onChangeCode} theme={theme} />
        ) : (
          <SingleEditor activeTab={activeTab} value={value} onChange={onChange} theme={theme} />
        )}
      </div>
    </div>
  );
}
