export default function ResizeHandle({ onMouseDown }) {
  return (
    <div
      onMouseDown={onMouseDown}
      className="absolute -right-3 -bottom-3 w-10 h-10 cursor-nwse-resize flex items-center justify-center z-50 group"
    >
      <div className="w-6 h-6 border-r-[3px] border-b-[3px] border-white/20 group-hover:border-pink-500 transition-all rounded-br-lg" />
    </div>
  );
}
