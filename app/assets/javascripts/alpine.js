function alpineMultiSelectController() {
  return {
    optgroups: [],
    options: [],
    selected: [],
    show: false,
    sourceFieldId: '',
    searchQuery: '',
    open() {
      this.show = true;
      // Focus search input after dropdown opens
      this.$nextTick(() => {
        if (this.$refs.searchInput) {
          this.$refs.searchInput.focus();
        }
      });
    },
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
      this.syncSelect();
    },
    remove(index, option) {
      this.options[option].selected = false;
      this.selected.splice(index, 1);
      this.syncSelect();
    },
    syncSelect() {
      const originalSelect = document.getElementById(this.sourceFieldId);
      originalSelect.innerHTML = '';
      
      this.options.filter(opt => opt.selected).forEach(opt => {
        const optionEl = document.createElement('option');
        optionEl.value = opt.value;
        optionEl.text = opt.text;
        optionEl.selected = true;
        originalSelect.appendChild(optionEl);
      });
      
      $(originalSelect).trigger('change');
    },
    loadOptions(fieldId, validTypes) {
      this.sourceFieldId = fieldId;
      const select = document.getElementById(fieldId);
      
      const preSelectedValues = Array.from(select.options).map(opt => opt.value);
      
      let runningOptionIndex = 0;
      const grouped = {};
      const allLinkables = window.notebookLinkables || [];
      
      allLinkables.forEach(linkable => {
        if (validTypes && !validTypes.includes(linkable.type)) {
          return;
        }
        
        if (!grouped[linkable.type]) {
          grouped[linkable.type] = [];
        }
        
        const isSelected = preSelectedValues.includes(linkable.raw_value);
        
        const optionData = {
          index: runningOptionIndex++,
          value: linkable.raw_value,
          text: linkable.name,
          imageUrl: linkable.imageUrl || '',
          icon: linkable.icon,
          icon_color: linkable.textColor,
          selected: isSelected
        };
        
        grouped[linkable.type].push(optionData);
        this.options.push(optionData);
        
        if (isSelected) {
          this.selected.push(optionData.index);
        }
      });
      
      Object.keys(grouped).forEach(type => {
        const typeOptions = grouped[type];
        if (typeOptions.length > 0) {
          let typeData = window.ContentTypeData ? window.ContentTypeData[type] : null;
          
          this.optgroups.push({
            label: type,
            icon: typeData ? typeData.icon : typeOptions[0].icon,
            color: typeData ? typeData.color : '',
            textColor: typeData ? typeData.text_color : typeOptions[0].icon_color,
            iconColor: typeData ? typeData.text_color : typeOptions[0].icon_color,
            plural: typeData ? typeData.plural : type + 's',
            options: typeOptions,
            filteredOptions: typeOptions
          });
        }
      });
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