import { ChevronRight, ChevronLeft, Trash2, Plus } from 'lucide-react';

export default function FooterNav({ canRemove, onAdd, onRemove }) {
  return (
    <div className="h-14 bg-black/40 flex items-center px-4 justify-between border-t-2 border-[#151515]">
      <div className="flex items-center gap-1">
        <ChevronLeft size={20} className="text-gray-700" />
        <div className="bg-[#111] px-4 py-1 rounded-sm border border-white/5">
          <span className="text-[7px] font-black uppercase text-gray-500 italic tracking-[0.2em]">ALKI_SYS</span>
        </div>
        <ChevronRight size={20} className="text-gray-700" />
      </div>

      <div className="flex gap-1.5 items-center">
        <button
          onClick={onAdd}
          className="w-7 h-7 bg-green-600 rounded flex items-center justify-center border-b-[3px] border-green-900 active:border-b-0 active:translate-y-0.5"
        >
          <Plus size={14} />
        </button>

        <button
          onClick={onRemove}
          disabled={!canRemove}
          className="w-7 h-7 bg-red-600 rounded flex items-center justify-center border-b-[3px] border-red-900 active:border-b-0 active:translate-y-0.5 disabled:opacity-40"
        >
          <Trash2 size={14} />
        </button>

        <div className="w-7 h-7 bg-blue-600 rounded-full border-2 border-white flex items-center justify-center font-black text-[9px] italic shadow-lg">
          U
        </div>
      </div>
    </div>
  );
}
