$(document).ready(function() {
  const yPadding = 16;
  const lineHeight = 20; // 36
  const minLines = 2; // Minimum number of lines to display
  const minHeight = yPadding + (minLines * lineHeight); // Minimum height for 2 lines
  
  const elements = document.getElementsByClassName('js-autosize-textarea');
  for (let i = 0; i < elements.length; i++) {
    // Set the initial height of the textarea
    const linesCount = Math.max(elements[i].value.split("\n").length, minLines);
    const contentHeight = yPadding + (linesCount * lineHeight);
    elements[i].setAttribute("style", "height:" + Math.max(contentHeight, minHeight) + "px;overflow-y:hidden;");

    // Resize the textarea whenever the value changes
    elements[i].addEventListener("input", OnInput, false);
  }

  function OnInput() {
    this.style.height = minHeight + "px";
    this.style.height = Math.max(this.scrollHeight, minHeight) + "px";
  }
});