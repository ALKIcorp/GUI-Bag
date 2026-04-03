export default function TopPanel({ isBooting, srcDoc, theme }) {
  return (
    <div
      className="flex-[4] border-[8px] rounded-t-[2rem] relative overflow-hidden flex flex-col"
      style={{ backgroundColor: theme.panel2, borderColor: theme.stroke }}
    >
      <div
        className="absolute inset-0 opacity-10 pointer-events-none"
        style={{ backgroundImage: `radial-gradient(${theme.appBg} 2px, transparent 0)`, backgroundSize: '8px 8px' }}
      ></div>

      <div
        className="flex-1 m-4 sm:m-6 rounded-lg z-10 overflow-hidden relative border-4 shadow-2xl"
        style={{ backgroundColor: theme.previewBg, borderColor: theme.stroke }}
      >
        {isBooting ? (
          <div className="w-full h-full flex items-center justify-center" style={{ backgroundColor: theme.editorBg }}>
            <div className="font-mono text-[9px] tracking-[0.5em] animate-pulse uppercase italic" style={{ color: theme.accent2 }}>
              LINKING...
            </div>
          </div>
        ) : (
          <iframe srcDoc={srcDoc} title="preview" sandbox="allow-scripts" className="w-full h-full border-none" />
        )}
      </div>
    </div>
  );
}
