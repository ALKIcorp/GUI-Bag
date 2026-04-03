import TopPanel from './TopPanel.jsx';
import BottomPanel from './BottomPanel.jsx';
import ResizeHandle from './ResizeHandle.jsx';

export default function ConsoleWindow({
  size,
  onResizeStart,
  isBooting,
  srcDoc,
  theme,
  themePresets,
  onSelectTheme,
  activeTab,
  onChangeTab,
  currentItem,
  items,
  selectedId,
  onSelectItem,
  onUpdateCode,
  onAddItem,
  onRemoveItem,
  onUpdateItem
}) {
  return (
    <div
      className="flex flex-col relative select-none rounded-[2.5rem] shadow-[0_50px_100px_-20px_rgba(0,0,0,1)] border-[1px] p-2"
      style={{
        width: `${size.width}px`,
        height: `${size.height}px`,
        backgroundColor: theme.editorBg,
        borderColor: `${theme.text}14`,
        color: theme.text
      }}
    >
      <TopPanel isBooting={isBooting} srcDoc={srcDoc} theme={theme} />

      <div className="h-6 flex justify-between items-center px-16 relative z-30" style={{ backgroundColor: theme.editorBg }}>
        <div className="w-14 h-1.5 rounded-full shadow-inner" style={{ backgroundColor: theme.appBg }}></div>
        <div className="w-14 h-1.5 rounded-full shadow-inner" style={{ backgroundColor: theme.appBg }}></div>
      </div>

      <BottomPanel
        theme={theme}
        themePresets={themePresets}
        onSelectTheme={onSelectTheme}
        activeTab={activeTab}
        onChangeTab={onChangeTab}
        currentItem={currentItem}
        items={items}
        selectedId={selectedId}
        onSelectItem={onSelectItem}
        onUpdateCode={onUpdateCode}
        onAddItem={onAddItem}
        onRemoveItem={onRemoveItem}
        onUpdateItem={onUpdateItem}
      />

      <ResizeHandle onMouseDown={onResizeStart} />
    </div>
  );
}
