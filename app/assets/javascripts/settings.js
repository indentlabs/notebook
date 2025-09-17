// Settings page JavaScript functionality
document.addEventListener('DOMContentLoaded', function() {
  // Toggle switches
  initializeToggleSwitches();
  
  // Form validation
  initializeFormValidation();
  
  // Password strength meter
  initializePasswordStrength();
  
  // Toast notifications
  initializeToasts();
  
  // Mobile navigation
  initializeMobileNav();
  
  // Tooltips
  initializeTooltips();
});

// Initialize toggle switches to replace checkboxes
function initializeToggleSwitches() {
  document.querySelectorAll('.toggle-switch').forEach(function(toggle) {
    toggle.addEventListener('click', function(e) {
      if (e.target.tagName !== 'INPUT') {
        const checkbox = this.querySelector('input[type="checkbox"]');
        checkbox.checked = !checkbox.checked;
        
        // Trigger change event for any listeners
        const event = new Event('change', { bubbles: true });
        checkbox.dispatchEvent(event);
        
        // Update toggle appearance
        updateToggleState(checkbox);
      }
    });
    
    // Set initial state
    const checkbox = toggle.querySelector('input[type="checkbox"]');
    updateToggleState(checkbox);
    
    // Listen for changes
    checkbox.addEventListener('change', function() {
      updateToggleState(this);
    });
  });
}

// Update toggle switch appearance based on checkbox state
function updateToggleState(checkbox) {
  const toggle = checkbox.closest('.toggle-switch');
  const toggleButton = toggle.querySelector('.toggle-dot');
  
  if (checkbox.checked) {
    toggle.classList.add('bg-notebook-blue');
    toggle.classList.remove('bg-gray-200');
    toggleButton.classList.add('translate-x-5');
    toggleButton.classList.remove('translate-x-0');
  } else {
    toggle.classList.remove('bg-notebook-blue');
    toggle.classList.add('bg-gray-200');
    toggleButton.classList.remove('translate-x-5');
    toggleButton.classList.add('translate-x-0');
  }
}

// Initialize form validation
function initializeFormValidation() {
  // Username validation
  const usernameField = document.getElementById('user_username');
  if (usernameField) {
    usernameField.addEventListener('input', function() {
      validateUsername(this);
    });
    
    // Initial validation
    if (usernameField.value) {
      validateUsername(usernameField);
    }
  }
  
  // Email validation
  const emailField = document.getElementById('user_email');
  if (emailField) {
    emailField.addEventListener('input', function() {
      validateEmail(this);
    });
    
    // Initial validation
    if (emailField.value) {
      validateEmail(emailField);
    }
  }
  
  // Character counters
  document.querySelectorAll('[data-max-length]').forEach(function(element) {
    const maxLength = element.getAttribute('data-max-length');
    const counter = document.createElement('div');
    counter.className = 'text-xs text-right text-gray-500 mt-1';
    counter.innerHTML = `<span class="current-length">${element.value.length}</span>/${maxLength}`;
    element.parentNode.appendChild(counter);
    
    element.addEventListener('input', function() {
      const currentLength = this.value.length;
      const counterElement = this.parentNode.querySelector('.current-length');
      counterElement.textContent = currentLength;
      
      if (currentLength > maxLength) {
        counterElement.classList.add('text-red-500');
      } else {
        counterElement.classList.remove('text-red-500');
      }
    });
  });
}

// Validate username
function validateUsername(field) {
  const username = field.value;
  const feedbackElement = field.parentNode.querySelector('.validation-feedback') || createFeedbackElement(field);
  
  // Clear previous validation classes
  field.classList.remove('border-red-300', 'border-green-300', 'focus:border-red-300', 'focus:border-green-300');
  
  if (username.length === 0) {
    feedbackElement.textContent = '';
    return;
  }
  
  // Simple validation - can be expanded
  const validUsernameRegex = /^[a-zA-Z0-9_\-$+!*]{1,40}$/;
  
  if (validUsernameRegex.test(username)) {
    field.classList.add('border-green-300', 'focus:border-green-300');
    feedbackElement.textContent = 'Username is valid';
    feedbackElement.className = 'validation-feedback text-xs text-green-600 mt-1';
  } else {
    field.classList.add('border-red-300', 'focus:border-red-300');
    feedbackElement.textContent = 'Username can only contain letters, numbers, and - _ $ + ! *';
    feedbackElement.className = 'validation-feedback text-xs text-red-600 mt-1';
  }
}

// Validate email
function validateEmail(field) {
  const email = field.value;
  const feedbackElement = field.parentNode.querySelector('.validation-feedback') || createFeedbackElement(field);
  
  // Clear previous validation classes
  field.classList.remove('border-red-300', 'border-green-300', 'focus:border-red-300', 'focus:border-green-300');
  
  if (email.length === 0) {
    feedbackElement.textContent = '';
    return;
  }
  
  // Simple email validation
  const validEmailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  
  if (validEmailRegex.test(email)) {
    field.classList.add('border-green-300', 'focus:border-green-300');
    feedbackElement.textContent = 'Email is valid';
    feedbackElement.className = 'validation-feedback text-xs text-green-600 mt-1';
  } else {
    field.classList.add('border-red-300', 'focus:border-red-300');
    feedbackElement.textContent = 'Please enter a valid email address';
    feedbackElement.className = 'validation-feedback text-xs text-red-600 mt-1';
  }
}

// Create feedback element for validation
function createFeedbackElement(field) {
  const feedbackElement = document.createElement('div');
  feedbackElement.className = 'validation-feedback text-xs mt-1';
  field.parentNode.appendChild(feedbackElement);
  return feedbackElement;
}

// Initialize password strength meter
function initializePasswordStrength() {
  const passwordField = document.getElementById('user_password');
  if (!passwordField) return;
  
  // Only show password strength on sign-up and password change pages
  // Check if we're on a sign-in page by looking for specific elements
  const isSignInPage = document.querySelector('form[action*="/users/sign_in"]') || 
                       document.querySelector('input[value="Sign In"]');
  
  if (isSignInPage) {
    // Don't show password strength on sign-in page
    return;
  }
  
  // Create strength meter
  const strengthMeter = document.createElement('div');
  strengthMeter.className = 'password-strength mt-2 hidden';
  strengthMeter.innerHTML = `
    <div class="flex space-x-1">
      <div class="h-1 w-1/4 rounded-full bg-gray-200" data-strength="1"></div>
      <div class="h-1 w-1/4 rounded-full bg-gray-200" data-strength="2"></div>
      <div class="h-1 w-1/4 rounded-full bg-gray-200" data-strength="3"></div>
      <div class="h-1 w-1/4 rounded-full bg-gray-200" data-strength="4"></div>
    </div>
    <p class="text-xs mt-1 text-gray-500 strength-text">Password strength</p>
  `;
  
  // Check if we're on sign-up page with two-column layout
  const passwordParent = passwordField.parentNode;
  const isSignUpPage = document.querySelector('form[action*="/users"]') && 
                       document.querySelector('input[name="user[password_confirmation]"]');
  
  if (isSignUpPage && passwordParent.classList.contains('flex-1')) {
    // On sign-up page, append the strength meter after the flex container
    const flexContainer = passwordParent.parentNode;
    if (flexContainer && flexContainer.classList.contains('flex')) {
      // Insert the strength meter after the flex container
      flexContainer.insertAdjacentElement('afterend', strengthMeter);
      // Make it span full width
      strengthMeter.classList.add('w-full', 'px-4');
    } else {
      passwordParent.appendChild(strengthMeter);
    }
  } else {
    // On other pages (like password change), append to the password field's parent
    passwordParent.appendChild(strengthMeter);
  }
  
  passwordField.addEventListener('input', function() {
    const password = this.value;
    
    if (password.length > 0) {
      strengthMeter.classList.remove('hidden');
      updatePasswordStrength(password, strengthMeter);
    } else {
      strengthMeter.classList.add('hidden');
    }
  });
}

// Update password strength meter
function updatePasswordStrength(password, meterElement) {
  // Calculate password strength (simplified version)
  let strength = 0;
  
  if (password.length >= 8) strength++;
  if (password.match(/[a-z]/) && password.match(/[A-Z]/)) strength++;
  if (password.match(/\d/)) strength++;
  if (password.match(/[^a-zA-Z\d]/)) strength++;
  
  // Update strength meter
  const strengthBars = meterElement.querySelectorAll('[data-strength]');
  const strengthText = meterElement.querySelector('.strength-text');
  
  strengthBars.forEach(bar => {
    const barStrength = parseInt(bar.getAttribute('data-strength'));
    
    if (barStrength <= strength) {
      bar.classList.remove('bg-gray-200');
      
      if (strength === 1) bar.classList.add('bg-red-500');
      else if (strength === 2) bar.classList.add('bg-orange-500');
      else if (strength === 3) bar.classList.add('bg-yellow-500');
      else bar.classList.add('bg-green-500');
    } else {
      bar.className = 'h-1 w-1/4 rounded-full bg-gray-200';
    }
  });
  
  // Update text
  if (strength === 0) strengthText.textContent = 'Password is too weak';
  else if (strength === 1) strengthText.textContent = 'Password is weak';
  else if (strength === 2) strengthText.textContent = 'Password is fair';
  else if (strength === 3) strengthText.textContent = 'Password is good';
  else strengthText.textContent = 'Password is strong';
  
  // Update text color
  strengthText.className = 'text-xs mt-1 ';
  if (strength === 0 || strength === 1) strengthText.className += 'text-red-500';
  else if (strength === 2) strengthText.className += 'text-orange-500';
  else if (strength === 3) strengthText.className += 'text-yellow-600';
  else strengthText.className += 'text-green-600';
}

// Initialize toast notifications
function initializeToasts() {
  window.showToast = function(message, type = 'success') {
    const toast = document.createElement('div');
    toast.className = 'fixed bottom-4 right-4 px-4 py-2 rounded-lg shadow-lg transform transition-all duration-500 translate-y-20 opacity-0 z-50';
    
    // Set color based on type
    if (type === 'success') {
      toast.classList.add('bg-green-500', 'text-white');
    } else if (type === 'error') {
      toast.classList.add('bg-red-500', 'text-white');
    } else if (type === 'info') {
      toast.classList.add('bg-blue-500', 'text-white');
    }
    
    toast.textContent = message;
    document.body.appendChild(toast);
    
    // Show toast
    setTimeout(() => {
      toast.classList.remove('translate-y-20', 'opacity-0');
    }, 100);
    
    // Hide toast after 3 seconds
    setTimeout(() => {
      toast.classList.add('translate-y-20', 'opacity-0');
      
      // Remove from DOM after animation
      setTimeout(() => {
        document.body.removeChild(toast);
      }, 500);
    }, 3000);
  };
  
  // Add event listeners to settings forms only
  // Only apply to forms on settings pages or forms with specific settings classes
  const settingsForms = document.querySelectorAll(
    '.settings-form, ' +
    'form[action*="/settings"], ' + 
    'form[action*="/customization"], ' +
    'form[action*="/billing"], ' +
    'form[action*="/account"]'
  );
  
  settingsForms.forEach(form => {
    form.addEventListener('submit', function() {
      // Store a flag in localStorage to show toast after redirect
      localStorage.setItem('showSettingsSavedToast', 'true');
    });
  });
  
  // Check if we need to show a toast (after redirect)
  if (localStorage.getItem('showSettingsSavedToast') === 'true') {
    showToast('Settings saved successfully!', 'success');
    localStorage.removeItem('showSettingsSavedToast');
  }
}

// Initialize mobile navigation
function initializeMobileNav() {
  const mobileNavToggle = document.getElementById('mobile-nav-toggle');
  const settingsSidebar = document.querySelector('.settings-sidebar-mobile');
  
  if (mobileNavToggle && settingsSidebar) {
    mobileNavToggle.addEventListener('click', function() {
      settingsSidebar.classList.toggle('translate-x-0');
      settingsSidebar.classList.toggle('-translate-x-full');
    });
  }
}

// Initialize tooltips
function initializeTooltips() {
  document.querySelectorAll('[data-tooltip]').forEach(element => {
    const tooltipText = element.getAttribute('data-tooltip');
    
    element.addEventListener('mouseenter', function(e) {
      const tooltip = document.createElement('div');
      tooltip.className = 'absolute z-10 px-3 py-2 text-sm font-medium text-white bg-gray-900 rounded-lg shadow-sm tooltip';
      tooltip.textContent = tooltipText;
      tooltip.style.top = `${e.target.offsetTop - 40}px`;
      tooltip.style.left = `${e.target.offsetLeft + (e.target.offsetWidth / 2) - 80}px`;
      
      document.body.appendChild(tooltip);
      
      // Position tooltip
      const rect = tooltip.getBoundingClientRect();
      if (rect.left < 0) {
        tooltip.style.left = '0px';
      } else if (rect.right > window.innerWidth) {
        tooltip.style.left = `${window.innerWidth - rect.width - 10}px`;
      }
      
      // Add arrow
      const arrow = document.createElement('div');
      arrow.className = 'tooltip-arrow';
      arrow.style.position = 'absolute';
      arrow.style.width = '10px';
      arrow.style.height = '10px';
      arrow.style.background = '#1F2937';
      arrow.style.transform = 'rotate(45deg)';
      arrow.style.bottom = '-5px';
      arrow.style.left = 'calc(50% - 5px)';
      tooltip.appendChild(arrow);
    });
    
    element.addEventListener('mouseleave', function() {
      const tooltip = document.querySelector('.tooltip');
      if (tooltip) {
        document.body.removeChild(tooltip);
      }
    });
  });
}