chrome.commands.onCommand.addListener((command) => {
  if ("open_popup" === command) {
    chrome.action.openPopup();
  }
  console.log(`Command "${command}" triggered`);
});
