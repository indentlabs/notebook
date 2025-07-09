// Collection Creation Wizard Controller
document.addEventListener('DOMContentLoaded', function() {
  // Only initialize if we're on the collection form page
  const collectionForm = document.getElementById('collection-form');
  if (!collectionForm) return;
  
  let currentStep = 1;
  const totalSteps = 4;
  
  // Initialize wizard
  initializeWizard();
  
  function initializeWizard() {
    // Set up step navigation
    setupStepNavigation();
    
    // Set up form interactions
    setupFormInteractions();
    
    
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
    // Step navigation buttons - allow free navigation between steps
    document.querySelectorAll('.step-nav').forEach(button => {
      if (button) {
        button.addEventListener('click', function() {
          const targetStep = parseInt(this.dataset.step);
          goToStep(targetStep);
        });
      }
    });
    
    // Next/Previous buttons
    document.querySelectorAll('.next-step').forEach(button => {
      if (button) {
        button.addEventListener('click', function() {
          if (validateCurrentStep()) {
            nextStep();
          }
        });
      }
    });
    
    document.querySelectorAll('.prev-step').forEach(button => {
      if (button) {
        button.addEventListener('click', function() {
          previousStep();
        });
      }
    });
  }
  
  function setupFormInteractions() {
    // Real-time form validation and preview updates
    const formInputs = document.querySelectorAll('#collection-form input, #collection-form textarea, #collection-form select');
    
    formInputs.forEach(input => {
      if (input) {
        input.addEventListener('input', function() {
          updatePreview();
          validateCurrentStep();
        });
        
        input.addEventListener('change', function() {
          updatePreview();
          validateCurrentStep();
        });
      }
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
      });
    }
    
    // Update checkbox UI when changed
    checkboxes.forEach(checkbox => {
      checkbox.addEventListener('change', function() {
        updateCheckboxUI(this);
        updatePreview();
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
    
    // Update step navigation appearance
    document.querySelectorAll('.step-nav').forEach(nav => {
      nav.classList.remove('active', 'completed');
    });
    
    // Mark current step as active
    const currentNav = document.querySelector(`[data-step="${stepNumber}"]`);
    if (currentNav) {
      currentNav.classList.add('active');
    }
    
    // Mark completed steps (steps that have valid data)
    updateStepCompletionStatus();
    
    currentStep = stepNumber;
    updateProgress();
  }
  
  function updateStepCompletionStatus() {
    // Step 1: Basic info
    if (validateBasicInfo()) {
      const step1Nav = document.querySelector('[data-step="1"]');
      if (step1Nav && !step1Nav.classList.contains('active')) {
        step1Nav.classList.add('completed');
      }
    }
    
    // Step 3: Content types
    if (validateContentTypes()) {
      const step3Nav = document.querySelector('[data-step="3"]');
      if (step3Nav && !step3Nav.classList.contains('active')) {
        step3Nav.classList.add('completed');
      }
    }
    
    // Step 4: Settings
    if (validateSettings()) {
      const step4Nav = document.querySelector('[data-step="4"]');
      if (step4Nav && !step4Nav.classList.contains('active')) {
        step4Nav.classList.add('completed');
      }
    }
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
  
  // Initialize toggle functionality
  initializeToggles();
  
  function initializeToggles() {
    const submissionToggle = document.querySelector('.submission-toggle');
    const autoAcceptToggle = document.querySelector('.auto-accept-toggle');
    const autoAcceptSetting = document.getElementById('auto-accept-setting');
    
    // Set up submission toggle
    if (submissionToggle) {
      submissionToggle.addEventListener('change', function() {
        if (autoAcceptSetting) {
          if (this.checked) {
            autoAcceptSetting.classList.remove('hidden');
          } else {
            autoAcceptSetting.classList.add('hidden');
            // Also uncheck auto-accept when submissions are disabled
            if (autoAcceptToggle) {
              autoAcceptToggle.checked = false;
            }
          }
        }
        updatePreview();
      });
    }
    
    // Set up auto-accept toggle
    if (autoAcceptToggle) {
      autoAcceptToggle.addEventListener('change', function() {
        updatePreview();
      });
    }
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
  
});