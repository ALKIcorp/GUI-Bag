import TopPanel from './TopPanel.jsx';
import BottomPanel from './BottomPanel.jsx';
import ResizeHandle from './ResizeHandle.jsx';

export default function ConsoleWindow({
  size,
  onResizeStart,
  isBooting,
  srcDoc,
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
      style={{ width: `${size.width}px`, height: `${size.height}px` }}
      className="flex flex-col relative select-none bg-[#151515] rounded-[2.5rem] shadow-[0_50px_100px_-20px_rgba(0,0,0,1)] border-[1px] border-white/5 p-2"
    >
      <TopPanel isBooting={isBooting} srcDoc={srcDoc} />

      <div className="h-6 bg-[#151515] flex justify-between items-center px-16 relative z-30">
        <div className="w-14 h-1.5 bg-[#0a0a0a] rounded-full shadow-inner"></div>
        <div className="w-14 h-1.5 bg-[#0a0a0a] rounded-full shadow-inner"></div>
      </div>

      <BottomPanel
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
