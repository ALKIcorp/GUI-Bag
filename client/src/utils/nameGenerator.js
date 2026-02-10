export function generateDefaultName(existingItems) {
  const defaultNames = existingItems
    .map(item => item.name)
    .filter(name => name.startsWith('UI Asset '));

  let maxNum = 0;
  for (const name of defaultNames) {
    const num = parseInt(name.replace('UI Asset ', ''), 10);
    if (!isNaN(num) && num > maxNum) {
      maxNum = num;
    }
  }

  return `UI Asset ${maxNum + 1}`;
}
