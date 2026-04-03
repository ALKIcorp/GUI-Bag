import CodeEditor from './CodeEditor.jsx';
import ItemList from './ItemList.jsx';
import FooterNav from './FooterNav.jsx';

export default function BottomPanel({
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
      className="flex-[5] border-[8px] rounded-b-[2rem] relative overflow-hidden flex flex-col"
      style={{ backgroundColor: theme.panel, borderColor: theme.stroke }}
    >
      <div className="flex flex-1 overflow-hidden">
        <CodeEditor
          theme={theme}
          activeTab={activeTab}
          onChangeTab={onChangeTab}
          value={currentItem?.[activeTab]}
          onChange={(value) => onUpdateCode(activeTab, value)}
          currentItem={currentItem}
          onChangeCode={onUpdateCode}
        />

        <ItemList theme={theme} items={items} selectedId={selectedId} onSelect={onSelectItem} onUpdateItem={onUpdateItem} />
      </div>

      <FooterNav
        theme={theme}
        themePresets={themePresets}
        onSelectTheme={onSelectTheme}
        canRemove={items.length > 1}
        onAdd={onAddItem}
        onRemove={onRemoveItem}
      />
    </div>
  );
}
