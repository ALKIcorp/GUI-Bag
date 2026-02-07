import { useEffect, useState } from 'react';

export function useBoot(delayMs = 600) {
  const [isBooting, setIsBooting] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => setIsBooting(false), delayMs);
    return () => clearTimeout(timer);
  }, [delayMs]);

  return isBooting;
}
