$(document).ready(function() {
  const yPadding = 16;
  const lineHeight = 20; // 36
  const elements = document.getElementsByClassName('js-autosize-textarea');
  for (let i = 0; i < elements.length; i++) {
    // Set the initial height of the textarea
    const linesCount = elements[i].value.split("\n").length;
    const contentHeight = yPadding + (linesCount * lineHeight);
    elements[i].setAttribute("style", "height:" + contentHeight + "px;overflow-y:hidden;");

    // Resize the textarea whenever the value changes
    elements[i].addEventListener("input", OnInput, false);
  }

  function OnInput() {
    this.style.height = lineHeight + "px";
    this.style.height = this.scrollHeight + "px";
  }
});