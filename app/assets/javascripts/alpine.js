function alpineMultiSelectController() {
  return {
    optgroups: [],
    options: [],
    selected: [],
    show: false,
    sourceFieldId: '',
    searchQuery: '',
    open() { this.show = true },
    close() { this.show = false },
    isOpen() { return this.show === true },
    filterOptions() {
      // Update filteredOptions for each optgroup based on search query
      this.optgroups.forEach(optgroup => {
        if (!this.searchQuery || this.searchQuery.trim() === '') {
          optgroup.filteredOptions = optgroup.options;
        } else {
          const query = this.searchQuery.toLowerCase();
          optgroup.filteredOptions = optgroup.options.filter(option =>
            option.text.toLowerCase().includes(query)
          );
        }
      });
    },
    select(index, event) {
      if (!this.options[index].selected) {
        this.options[index].selected = true;
        this.options[index].element = event.target;
        this.selected.push(index);

      } else {
        this.selected.splice(this.selected.lastIndexOf(index), 1);
        this.options[index].selected = false;
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

      // We also want to manually remove the `selected` attribute from the
      // original select element's option.
      const originalSelect = document.getElementById(this.sourceFieldId);
      originalSelect.options[option].selected = false;

      // After removing the option, we want to emit a change event to trigger
      // a field autosave.
      originalSelect.dispatchEvent(new Event('change'));
    },
    loadOptions(fieldId) {
      this.sourceFieldId = fieldId;
      const select = document.getElementById(fieldId);
      const optgroups = select.getElementsByTagName('optgroup');

      // Since we're effectively resetting indices per optgroup, we need to track
      // a single running index throughout all optgroups to use as an index for
      // each option for events, etc.
      let runningOptionIndex = 0;

      // For each optgroup (page type)...
      for (let i = 0; i < optgroups.length; i++) {
        const groupOptions = optgroups[i].getElementsByTagName('option');

        // Prepare the `options` array for this optgroup
        const optionsForThisOptGroup = [];
        for (let j = 0; j < groupOptions.length; j++) {
          const option = groupOptions[j];
          const imageUrl = option.getAttribute('data-image-url');
      
          optionsForThisOptGroup.push({
            index: runningOptionIndex++,
            value: option.value,
            text: option.textContent.trim(),
            imageUrl: imageUrl,
            icon: option.getAttribute('data-icon'),
            icon_color: option.getAttribute('data-icon-color'),
            selected: !!option.selected
          });

          if (!!option.selected) {
            this.selected.push(runningOptionIndex - 1);
          }
        }

        // Finally, add it as a valid optgroup with options
        if (optionsForThisOptGroup.length > 0) {
          const optgroupData = {
            label: optgroups[i].label,
            icon: window.ContentTypeData[optgroups[i].label].icon,
            color: window.ContentTypeData[optgroups[i].label].color,
            iconColor: window.ContentTypeData[optgroups[i].label].text_color || 'text-gray-600',
            plural: window.ContentTypeData[optgroups[i].label].plural,
            options: optionsForThisOptGroup,
            filteredOptions: optionsForThisOptGroup // Initialize with all options
          };
          this.optgroups.push(optgroupData);

          // And also track all the options in a flat array so we can reference them with a single index
          for (let j = 0; j < optionsForThisOptGroup.length; j++) {
            this.options.push(optionsForThisOptGroup[j]);
          }
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