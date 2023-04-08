document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
  anchor.addEventListener('click', function (e) {
    e.preventDefault();

    const target = document.querySelector(this.getAttribute('href'));

    // Check if the target element exists
    if (target) {
      window.scrollTo({
        top: target.offsetTop,
        behavior: 'smooth',
      });
    }
  });
});