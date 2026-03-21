// Timeline Form Helpers
// Extracted from timelines/edit.html.erb for reusability

// Global function for updating timeline tags
function updateTimelineTags(timelineId, tags) {
  const tagString = tags.join(',,,|||,,,');
  console.log('Sending tags:', tagString, 'from array:', tags);

  // Create a temporary form to submit the tag update
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = `/plan/timelines/${timelineId}`;
  form.style.display = 'none';

  // Add CSRF token
  const csrfInput = document.createElement('input');
  csrfInput.type = 'hidden';
  csrfInput.name = 'authenticity_token';
  csrfInput.value = document.querySelector('meta[name=csrf-token]').content;
  form.appendChild(csrfInput);

  // Add method override for PATCH
  const methodInput = document.createElement('input');
  methodInput.type = 'hidden';
  methodInput.name = '_method';
  methodInput.value = 'patch';
  form.appendChild(methodInput);

  // Add tags field - send all current tags
  const tagsInput = document.createElement('input');
  tagsInput.type = 'hidden';
  tagsInput.name = 'timeline[page_tags]';
  tagsInput.value = tagString;
  form.appendChild(tagsInput);

  // Submit form
  document.body.appendChild(form);
  return fetch(form.action, {
    method: 'PATCH',
    body: new FormData(form),
    headers: {
      'X-CSRF-Token': csrfInput.value,
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest'
    }
  })
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    return response.json();
  })
  .then(data => {
    console.log('Tags update successful:', data);
    // Set status to indicate successful save
    const alpineEl = document.querySelector('[x-data*="timelineEditor"]');
    if (alpineEl && window.Alpine) {
      Alpine.$data(alpineEl).autoSaveStatus = 'saved';
      setTimeout(() => {
        if (Alpine.$data(alpineEl).autoSaveStatus === 'saved') {
          Alpine.$data(alpineEl).autoSaveStatus = 'saved';
        }
      }, 2000);
    }
  })
  .catch(error => {
    console.error('Error updating tags:', error);
    // Revert to server state on error by reloading
    location.reload();
  })
  .finally(() => {
    document.body.removeChild(form);
  });
}

// Helper function to submit forms remotely
function submitFormRemotely(form) {
  if (form.getAttribute('data-remote') !== 'true') {
    form.setAttribute('data-remote', 'true');
  }

  // Use Rails UJS to submit the form remotely
  if (typeof Rails !== 'undefined' && Rails.fire) {
    Rails.fire(form, 'submit');
  } else {
    // Manual AJAX implementation since Rails UJS is not working
    submitFormWithFetch(form);
  }
}

// Manual AJAX form submission function
function submitFormWithFetch(form) {
  // Set auto-save status to saving
  const alpineEl = document.querySelector('[x-data]');
  if (alpineEl) {
    Alpine.$data(alpineEl).autoSaveStatus = 'saving';
  }

  const formData = new FormData(form);
  const url = form.action;
  const method = form.method.toUpperCase();

  // Add Rails authenticity token if not present
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
  if (csrfToken && !formData.has('authenticity_token')) {
    formData.append('authenticity_token', csrfToken);
  }

  fetch(url, {
    method: method,
    body: formData,
    headers: {
      'X-CSRF-Token': csrfToken,
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest'
    }
  })
  .then(response => {
    if (response.ok) {
      return response.json();
    } else {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
  })
  .then(data => {
    // Trigger success event manually
    const successEvent = new CustomEvent('ajax:success', {
      detail: [data],
      bubbles: true,
      cancelable: true
    });
    form.dispatchEvent(successEvent);

    // Update auto-save status
    if (alpineEl) {
      Alpine.$data(alpineEl).autoSaveStatus = 'saved';
      setTimeout(() => {
        Alpine.$data(alpineEl).autoSaveStatus = 'saved';
      }, 2000);
    }
  })
  .catch(error => {
    // Trigger error event manually
    const errorEvent = new CustomEvent('ajax:error', {
      detail: [null, { status: 'error', message: error.message }],
      bubbles: true,
      cancelable: true
    });
    form.dispatchEvent(errorEvent);

    // Update auto-save status
    if (alpineEl) {
      Alpine.$data(alpineEl).autoSaveStatus = 'error';
    }
  });
}
