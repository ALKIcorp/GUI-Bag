export const INITIAL_DATA = [
  {
    id: '1',
    name: 'Super Potion',
    type: 'UI Component',
    html: '<button class="potion-btn">Heal 50HP</button>',
    css: `.potion-btn {
  padding: 12px 24px;
  background: #ff7675;
  color: white;
  border: 4px solid #d63031;
  border-radius: 4px;
  font-family: sans-serif;
  font-weight: bold;
  cursor: pointer;
  box-shadow: 0 4px 0 #d63031;
}
.potion-btn:active {
  transform: translateY(2px);
  box-shadow: 0 2px 0 #d63031;
}`,
    js: "document.querySelector('.potion-btn').onclick = () => console.log('HP Restored!');"
  },
  {
    id: '2',
    name: 'Lemonade',
    type: 'Beverage',
    html: '<div class="lemon-loader"></div>',
    css: `.lemon-loader {
  width: 40px;
  height: 40px;
  border: 4px solid #ffe66d;
  border-top: 4px solid transparent;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}
@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }`,
    js: ''
  }
];
