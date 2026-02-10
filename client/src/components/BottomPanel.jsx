import CodeEditor from './CodeEditor.jsx';
import ItemList from './ItemList.jsx';
import FooterNav from './FooterNav.jsx';

export default function BottomPanel({
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
    <div className="flex-[5] bg-[#a91d3a] border-[8px] border-[#151515] rounded-b-[2rem] relative overflow-hidden flex flex-col">
      <div className="flex flex-1 overflow-hidden">
        <CodeEditor
          activeTab={activeTab}
          onChangeTab={onChangeTab}
          value={currentItem?.[activeTab]}
          onChange={(value) => onUpdateCode(activeTab, value)}
        />

        <ItemList items={items} selectedId={selectedId} onSelect={onSelectItem} onUpdateItem={onUpdateItem} />
      </div>

      <FooterNav canRemove={items.length > 1} onAdd={onAddItem} onRemove={onRemoveItem} />
    </div>
  );
}
