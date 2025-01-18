var isPanelOpen = false

function openRightPanel(event) {
  if (!isPanelOpen) {
    isPanelOpen = true
    event.preventDefault();
    document.getElementById('rightPanel').classList.remove('hidden');
    document.getElementById('rightPanel').classList.remove('translate-x-full');
  }else{
    isPanelOpen = false
    document.getElementById('rightPanel').classList.add('hidden');
    document.getElementById('rightPanel').classList.add('translate-x-full');
  }

}
