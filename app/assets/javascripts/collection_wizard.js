// Collection Creation Wizard Controller
document.addEventListener('DOMContentLoaded', function() {
  let currentStep = 1;
  const totalSteps = 4;
  
  // Initialize wizard
  initializeWizard();
  
  function initializeWizard() {
    // Set up step navigation
    setupStepNavigation();
    
    // Set up form interactions
    setupFormInteractions();
    
    // Set up auto-save
    setupAutoSave();
    
    // Set up content type selection
    setupContentTypeSelection();
    
    // Set up theme selection
    setupThemeSelection();
    
    // Initialize preview
    updatePreview();
    
    // Update progress
    updateProgress();
  }
  
  function setupStepNavigation() {
    // Step navigation buttons
    document.querySelectorAll('.step-nav').forEach(button => {
      button.addEventListener('click', function() {
        const targetStep = parseInt(this.dataset.step);
        if (targetStep <= getCompletedSteps() + 1) {
          goToStep(targetStep);
        }
      });
    });
    
    // Next/Previous buttons
    document.querySelectorAll('.next-step').forEach(button => {
      button.addEventListener('click', function() {
        if (validateCurrentStep()) {
          nextStep();
        }
      });
    });
    
    document.querySelectorAll('.prev-step').forEach(button => {
      button.addEventListener('click', function() {
        previousStep();
      });
    });
  }
  
  function setupFormInteractions() {
    // Real-time form validation and preview updates
    const formInputs = document.querySelectorAll('#collection-form input, #collection-form textarea, #collection-form select');
    
    formInputs.forEach(input => {
      input.addEventListener('input', function() {
        updatePreview();
        validateCurrentStep();
        markAsModified();
      });
      
      input.addEventListener('change', function() {
        updatePreview();
        validateCurrentStep();
        markAsModified();
      });
    });
    
    // Character counter for description
    const descriptionField = document.querySelector('textarea[name="page_collection[description]"]');
    const charCounter = document.getElementById('char-count');
    
    if (descriptionField && charCounter) {
      descriptionField.addEventListener('input', function() {
        updateCharCount();
      });
      updateCharCount();
    }
    
    function updateCharCount() {
      const count = descriptionField.value.length;
      charCounter.textContent = `${count} / 500`;
      
      if (count > 450) {
        charCounter.classList.add('text-red-600');
        charCounter.classList.remove('text-amber-600');
      } else if (count > 400) {
        charCounter.classList.add('text-amber-600');
        charCounter.classList.remove('text-red-600');
      } else {
        charCounter.classList.remove('text-amber-600', 'text-red-600');
      }
    }
  }
  
  function setupAutoSave() {
    let saveTimeout;
    let isModified = false;
    
    window.markAsModified = function() {
      isModified = true;
      updateSaveStatus('saving');
      
      clearTimeout(saveTimeout);
      saveTimeout = setTimeout(() => {
        if (isModified) {
          saveDraft();
        }
      }, 2000);
    };
    
    function saveDraft() {
      // Simulate auto-save (in a real app, this would make an AJAX request)
      updateSaveStatus('saving');
      
      setTimeout(() => {
        updateSaveStatus('saved');
        isModified = false;
      }, 1000);
    }
    
    function updateSaveStatus(status) {
      const saveStatus = document.getElementById('save-status');
      const saveIndicator = document.querySelector('.auto-save-indicator');
      
      if (saveStatus && saveIndicator) {
        saveIndicator.className = `auto-save-indicator ${status}`;
        
        switch(status) {
          case 'saving':
            saveStatus.textContent = 'Saving changes...';
            break;
          case 'saved':
            saveStatus.textContent = 'All changes saved';
            break;
          case 'error':
            saveStatus.textContent = 'Error saving changes';
            break;
        }
      }
    }
    
    // Manual save draft button
    const saveDraftButton = document.getElementById('save-draft');
    if (saveDraftButton) {
      saveDraftButton.addEventListener('click', function() {
        saveDraft();
      });
    }
  }
  
  function setupContentTypeSelection() {
    const selectAllBtn = document.getElementById('select-all-types');
    const selectNoneBtn = document.getElementById('select-none-types');
    const selectCommonBtn = document.getElementById('select-common-types');
    const checkboxes = document.querySelectorAll('.content-type-checkbox');
    
    if (selectAllBtn) {
      selectAllBtn.addEventListener('click', function(e) {
        e.preventDefault();
        checkboxes.forEach(checkbox => {
          checkbox.checked = true;
          updateCheckboxUI(checkbox);
        });
        updatePreview();
        markAsModified();
      });
    }
    
    if (selectNoneBtn) {
      selectNoneBtn.addEventListener('click', function(e) {
        e.preventDefault();
        checkboxes.forEach(checkbox => {
          checkbox.checked = false;
          updateCheckboxUI(checkbox);
        });
        updatePreview();
        markAsModified();
      });
    }
    
    if (selectCommonBtn) {
      selectCommonBtn.addEventListener('click', function(e) {
        e.preventDefault();
        checkboxes.forEach(checkbox => {
          checkbox.checked = checkbox.dataset.common === 'true';
          updateCheckboxUI(checkbox);
        });
        updatePreview();
        markAsModified();
      });
    }
    
    // Update checkbox UI when changed
    checkboxes.forEach(checkbox => {
      checkbox.addEventListener('change', function() {
        updateCheckboxUI(this);
        updatePreview();
        markAsModified();
      });
      // Initialize UI
      updateCheckboxUI(checkbox);
    });
  }
  
  function updateCheckboxUI(checkbox) {
    const label = checkbox.closest('label');
    const customCheckbox = label.querySelector('.checkbox-custom');
    const checkIcon = label.querySelector('.check-icon');
    
    if (checkbox.checked) {
      customCheckbox.classList.add('bg-blue-500', 'border-blue-500');
      customCheckbox.classList.remove('border-gray-300');
      checkIcon.classList.remove('opacity-0');
      checkIcon.classList.add('opacity-100');
      label.classList.add('ring-2', 'ring-blue-500', 'ring-opacity-20');
    } else {
      customCheckbox.classList.remove('bg-blue-500', 'border-blue-500');
      customCheckbox.classList.add('border-gray-300');
      checkIcon.classList.add('opacity-0');
      checkIcon.classList.remove('opacity-100');
      label.classList.remove('ring-2', 'ring-blue-500', 'ring-opacity-20');
    }
  }
  
  function setupThemeSelection() {
    const themeOptions = document.querySelectorAll('.theme-option');
    
    themeOptions.forEach(option => {
      option.addEventListener('click', function() {
        // Remove active class from all options
        themeOptions.forEach(opt => opt.classList.remove('active'));
        
        // Add active class to clicked option
        this.classList.add('active');
        
        // Update preview theme
        updatePreviewTheme(this.dataset.theme);
        markAsModified();
      });
    });
  }
  
  function updatePreviewTheme(theme) {
    const previewHeader = document.getElementById('preview-header');
    if (!previewHeader) return;
    
    // Remove existing theme classes
    previewHeader.className = previewHeader.className.replace(/from-\w+-\d+|to-\w+-\d+/g, '');
    
    // Apply new theme
    switch(theme) {
      case 'warm':
        previewHeader.classList.add('from-orange-500', 'to-red-600');
        break;
      case 'nature':
        previewHeader.classList.add('from-green-500', 'to-emerald-600');
        break;
      case 'monochrome':
        previewHeader.classList.add('from-gray-500', 'to-gray-800');
        break;
      default:
        previewHeader.classList.add('from-blue-500', 'to-purple-600');
    }
  }
  
  function goToStep(stepNumber) {
    if (stepNumber < 1 || stepNumber > totalSteps) return;
    
    // Hide all steps
    document.querySelectorAll('.form-step').forEach(step => {
      step.classList.remove('active');
    });
    
    // Show target step
    const targetStep = document.getElementById(`step-${stepNumber}`);
    if (targetStep) {
      targetStep.classList.add('active');
    }
    
    // Update step navigation
    document.querySelectorAll('.step-nav').forEach(nav => {
      nav.classList.remove('active', 'completed');
    });
    
    // Mark completed steps
    for (let i = 1; i < stepNumber; i++) {
      const nav = document.querySelector(`[data-step="${i}"]`);
      if (nav) nav.classList.add('completed');
    }
    
    // Mark current step as active
    const currentNav = document.querySelector(`[data-step="${stepNumber}"]`);
    if (currentNav) currentNav.classList.add('active');
    
    currentStep = stepNumber;
    updateProgress();
  }
  
  function nextStep() {
    if (currentStep < totalSteps) {
      goToStep(currentStep + 1);
    }
  }
  
  function previousStep() {
    if (currentStep > 1) {
      goToStep(currentStep - 1);
    }
  }
  
  function validateCurrentStep() {
    switch(currentStep) {
      case 1:
        return validateBasicInfo();
      case 2:
        return true; // Visual design is optional
      case 3:
        return validateContentTypes();
      case 4:
        return validateSettings();
      default:
        return true;
    }
  }
  
  function validateBasicInfo() {
    const titleInput = document.querySelector('input[name="page_collection[title]"]');
    return titleInput && titleInput.value.trim().length > 0;
  }
  
  function validateContentTypes() {
    const checkboxes = document.querySelectorAll('.content-type-checkbox');
    return Array.from(checkboxes).some(checkbox => checkbox.checked);
  }
  
  function validateSettings() {
    const privacyRadios = document.querySelectorAll('input[name="page_collection[privacy]"]');
    return Array.from(privacyRadios).some(radio => radio.checked);
  }
  
  function getCompletedSteps() {
    let completed = 0;
    if (validateBasicInfo()) completed = Math.max(completed, 1);
    if (validateContentTypes()) completed = Math.max(completed, 3);
    if (validateSettings()) completed = Math.max(completed, 4);
    return completed;
  }
  
  function updateProgress() {
    const progressBar = document.getElementById('progress-bar');
    const progressText = document.getElementById('progress-text');
    
    if (progressBar && progressText) {
      const progress = (currentStep / totalSteps) * 100;
      progressBar.style.width = `${progress}%`;
      progressText.textContent = `Step ${currentStep} of ${totalSteps}`;
    }
  }
  
  function updatePreview() {
    if (window.updateCollectionPreview) {
      window.updateCollectionPreview();
    }
  }
  
  // Submission toggle
  const submissionToggle = document.querySelector('.submission-toggle');
  if (submissionToggle) {
    submissionToggle.addEventListener('change', function() {
      updatePreview();
      markAsModified();
    });
  }
  
  // Keyboard navigation
  document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowRight' && e.ctrlKey) {
      e.preventDefault();
      if (validateCurrentStep()) nextStep();
    } else if (e.key === 'ArrowLeft' && e.ctrlKey) {
      e.preventDefault();
      previousStep();
    }
  });
  
  // Prevent accidental navigation away
  window.addEventListener('beforeunload', function(e) {
    const saveStatus = document.getElementById('save-status');
    if (saveStatus && saveStatus.textContent.includes('Saving')) {
      e.preventDefault();
      e.returnValue = '';
    }
  });
});