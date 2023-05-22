function alpineMultiSelectController() {
  return {
    optgroups: [],
    options: [],
    selected: [],
    show: false,
    sourceFieldId: '',
    open() { this.show = true },
    close() { this.show = false },
    isOpen() { return this.show === true },
    select(index, event) {
      if (!this.options[index].selected) {
        this.options[index].selected = true;
        this.options[index].element = event.target;
        this.selected.push(index);

      } else {
        this.selected.splice(this.selected.lastIndexOf(index), 1);
        this.options[index].selected = false
      }

      // Update the original select element's selected options
      const originalSelect = document.getElementById(this.sourceFieldId);
      for (let i = 0; i < originalSelect.options.length; i++) {
        originalSelect.options[i].selected = this.options[i].selected;
      }

      // Finally, trigger a manual on-change event on the original select
      // to make sure our autosave fires on it.
      originalSelect.dispatchEvent(new Event('change'));
    },
    select(groupIndex, optionIndex, event) { // WE ARE HERE -- click from html
      if (!this.options[index].selected) {
        this.options[index].selected = true;
        this.options[index].element = event.target;
        this.selected.push(index);

      } else {
        this.selected.splice(this.selected.lastIndexOf(index), 1);
        this.options[index].selected = false
      }

      // Update the original select element's selected options
      const originalSelect = document.getElementById(this.sourceFieldId);
      for (let i = 0; i < originalSelect.options.length; i++) {
        originalSelect.options[i].selected = this.options[i].selected;
      }

      // Finally, trigger a manual on-change event on the original select
      // to make sure our autosave fires on it.
      originalSelect.dispatchEvent(new Event('change'));
    },
    remove(index, option) {
      this.options[option].selected = false;
      this.selected.splice(index, 1);
    },
    loadOptions(fieldId) {
      this.sourceFieldId = fieldId;
      const select = document.getElementById(fieldId);
      const optgroups = select.getElementsByTagName('optgroup');

      // For each optgroup (page type)...
      for (let i = 0; i < optgroups.length; i++) {
        const groupOptions = optgroups[i].getElementsByTagName('option');

        // Prepare the `options` array for this optgroup
        const optionsForThisOptGroup = [];
        for (let j = 0; j < groupOptions.length; j++) {
          const option = groupOptions[j];
          const imageUrl = option.getAttribute('data-image-url');
      
          optionsForThisOptGroup.push({
            value: option.value,
            text: option.textContent.trim(),
            imageUrl: imageUrl
          });
        }

        // Finally, add it as a valid optgroup with options
        if (optionsForThisOptGroup.length > 0) {
          this.optgroups.push({
            label: optgroups[i].label,
            icon: window.ContentTypeData[optgroups[i].label].icon,
            color: window.ContentTypeData[optgroups[i].label].color,
            plural: window.ContentTypeData[optgroups[i].label].plural,
            options: optionsForThisOptGroup
          });
        }
      }

      for (let i = 0; i < select.length; i++) {
        this.options.push({
          value: select[i].value,
          text: select[i].innerText,
          selected: !!select[i].selected
        });

        // Default anything already-selected to actively selected
        if (!!select[i].selected) {
          this.selected.push(i);
        }
      }
    },
    selectedValues(){
      // Return all this.options where selected=true
      return this.options.filter(op => op.selected === true); // .map(el => el.text)
      // return this.selected.map((option)=>{
      //   return this.options[option].value;
      // });
    }
  }
}