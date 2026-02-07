import { useCallback, useRef, useState } from 'react';

export function useResize({ minWidth = 380, minHeight = 580, initialWidth = 480, initialHeight = 720 } = {}) {
  const [size, setSize] = useState({ width: initialWidth, height: initialHeight });
  const resizingRef = useRef(null);

  const doResize = useCallback((e) => {
    if (!resizingRef.current) return;

    const deltaX = e.clientX - resizingRef.current.startX;
    const deltaY = e.clientY - resizingRef.current.startY;

    setSize({
      width: Math.max(minWidth, resizingRef.current.startWidth + deltaX),
      height: Math.max(minHeight, resizingRef.current.startHeight + deltaY)
    });
  }, [minWidth, minHeight]);

  const stopResize = useCallback(() => {
    resizingRef.current = null;
    document.removeEventListener('mousemove', doResize);
    document.removeEventListener('mouseup', stopResize);
    document.body.style.cursor = 'default';
  }, [doResize]);

  const startResize = useCallback((e) => {
    e.preventDefault();
    resizingRef.current = {
      startWidth: size.width,
      startHeight: size.height,
      startX: e.clientX,
      startY: e.clientY
    };

    document.addEventListener('mousemove', doResize);
    document.addEventListener('mouseup', stopResize);
    document.body.style.cursor = 'nwse-resize';
  }, [size.width, size.height, doResize, stopResize]);

  return { size, startResize };
}
