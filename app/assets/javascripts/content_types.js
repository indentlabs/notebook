// x-on:click="enabled = !enabled; togglePageType('Character', enabled)"
function togglePageType(content_type, active) {
  const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  fetch('/customization/toggle_content_type', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken
    },
    body: JSON.stringify({
      content_type: content_type,
      active: active ? 'on' : 'off'
    })
  })
  .then(response => {
    // Handle the response
    console.log('toggled successfully');
  })
  .catch(error => {
    // Handle the error
    console.log('couldnt toggle');
  });
}
