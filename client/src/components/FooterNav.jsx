import { useEffect, useRef, useState } from 'react';
import { ChevronRight, ChevronLeft, Trash2, Plus, Check, SlidersHorizontal } from 'lucide-react';

function ThemeMenu({ theme, themePresets, onSelectTheme, onClose }) {
  return (
    <div
      className="absolute bottom-10 right-0 w-80 rounded-2xl border p-2 shadow-2xl z-50"
      style={{ backgroundColor: theme.editorBg, borderColor: theme.stroke, color: theme.text }}
    >
      <div className="px-2 pt-1 pb-2 border-b" style={{ borderBottomColor: `${theme.text}14` }}>
        <div className="text-[9px] font-black tracking-[0.3em] uppercase" style={{ color: theme.accent2 }}>
          Themes
        </div>
        <div className="text-[10px] mt-1" style={{ color: theme.mutedText }}>
          Mood presets
        </div>
      </div>

      <div className="max-h-72 overflow-y-auto custom-scroll pr-1 mt-2 space-y-1">
        {themePresets.map((preset) => {
          const isActive = preset.name === theme.name;

          return (
            <button
              key={preset.name}
              type="button"
              onClick={() => {
                onSelectTheme(preset);
                onClose();
              }}
              className="w-full rounded-xl border px-3 py-2 text-left transition-colors"
              style={{
                backgroundColor: isActive ? preset.panel2 : preset.panel,
                borderColor: isActive ? preset.accent2 : preset.stroke,
                color: preset.text
              }}
            >
              <div className="flex items-center justify-between gap-3">
                <div>
                  <div className="text-[10px] font-black uppercase tracking-[0.18em]">{preset.name}</div>
                  <div className="text-[9px] mt-1" style={{ color: preset.mutedText }}>
                    {preset.panel} / {preset.accent2}
                  </div>
                </div>
                {isActive ? <Check size={14} style={{ color: preset.accent }} /> : null}
              </div>
              <div className="flex gap-1 mt-2">
                {[preset.appBg, preset.panel, preset.panel2, preset.accent, preset.accent2].map((color) => (
                  <span
                    key={color}
                    className="block h-3 flex-1 rounded-full border"
                    style={{ backgroundColor: color, borderColor: `${preset.text}22` }}
                  />
                ))}
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}

export default function FooterNav({ theme, themePresets, onSelectTheme, canRemove, onAdd, onRemove }) {
  const [isThemeMenuOpen, setIsThemeMenuOpen] = useState(false);
  const themeMenuRef = useRef(null);

  useEffect(() => {
    if (!isThemeMenuOpen) return undefined;

    const handlePointerDown = (event) => {
      if (!themeMenuRef.current?.contains(event.target)) {
        setIsThemeMenuOpen(false);
      }
    };

    window.addEventListener('pointerdown', handlePointerDown);
    return () => window.removeEventListener('pointerdown', handlePointerDown);
  }, [isThemeMenuOpen]);

  return (
    <div className="h-14 flex items-center px-4 justify-between border-t-2 relative z-50" style={{ backgroundColor: `${theme.appBg}A6`, borderTopColor: theme.stroke }}>
      <div className="flex items-center gap-1">
        <ChevronLeft size={20} style={{ color: theme.mutedText }} />
        <div className="px-4 py-1 rounded-sm border" style={{ backgroundColor: theme.editorBg, borderColor: `${theme.text}0D` }}>
          <span className="text-[7px] font-black uppercase italic tracking-[0.2em]" style={{ color: theme.mutedText }}>
            ALKI_SYS
          </span>
        </div>
        <ChevronRight size={20} style={{ color: theme.mutedText }} />
      </div>

      <div className="flex gap-1.5 items-center pr-3 pb-1 relative z-[70] pointer-events-auto">
        <button
          onClick={onAdd}
          className="w-7 h-7 rounded flex items-center justify-center border-b-[3px] active:border-b-0 active:translate-y-0.5"
          style={{ backgroundColor: theme.success, borderBottomColor: theme.appBg, color: theme.editorBg }}
        >
          <Plus size={14} />
        </button>

        <button
          onClick={onRemove}
          disabled={!canRemove}
          className="w-7 h-7 rounded flex items-center justify-center border-b-[3px] active:border-b-0 active:translate-y-0.5 disabled:opacity-40"
          style={{ backgroundColor: theme.danger, borderBottomColor: theme.appBg, color: theme.editorBg }}
        >
          <Trash2 size={14} />
        </button>

        <div className="relative z-[80] pointer-events-auto" ref={themeMenuRef}>
          {isThemeMenuOpen ? (
            <ThemeMenu
              theme={theme}
              themePresets={themePresets}
              onSelectTheme={onSelectTheme}
              onClose={() => setIsThemeMenuOpen(false)}
            />
          ) : null}

          <button
            type="button"
            onClick={() => setIsThemeMenuOpen((open) => !open)}
            className="relative z-[90] h-8 px-3 rounded-full border-[3px] flex items-center justify-center gap-1.5 font-black text-[8px] uppercase tracking-[0.18em] shadow-lg pointer-events-auto"
            style={{
              backgroundColor: theme.accent2,
              borderColor: theme.accent,
              color: theme.previewBg
            }}
            title="Open settings"
            aria-label="Open settings"
          >
            <SlidersHorizontal size={12} />
            <span>Settings</span>
          </button>
        </div>
      </div>
    </div>
  );
}
