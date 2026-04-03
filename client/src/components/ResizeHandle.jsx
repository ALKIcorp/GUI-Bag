export default function ResizeHandle({ onMouseDown }) {
  return (
    <div
      className="absolute -right-3 -bottom-3 w-10 h-10 flex items-center justify-center z-40 pointer-events-none group"
    >
      <button
        type="button"
        onMouseDown={onMouseDown}
        aria-label="Resize window"
        className="w-6 h-6 cursor-nwse-resize pointer-events-auto border-r-[3px] border-b-[3px] border-white/20 group-hover:border-pink-500 transition-all rounded-br-lg"
      />
    </div>
  );
}
