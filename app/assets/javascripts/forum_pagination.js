// Page dropdown in the forum paginator (app/views/thredded/kaminari/_paginator).
// The server only renders the current page as an option, so long threads don't
// pay for thousands of URLs; the rest are filled in here.
(function () {
  var PAGE_NUMBER_PLACEHOLDER = '987654321'; // ForumPaginationHelper::PAGE_NUMBER_PLACEHOLDER

  function pageUrl(select, number) {
    if (number === 1) return select.dataset.firstPageUrl;
    return select.dataset.pageUrlTemplate.replace(PAGE_NUMBER_PLACEHOLDER, number);
  }

  function setUp(select) {
    var total = parseInt(select.dataset.totalPages, 10);
    var current = parseInt(select.value, 10);
    var options = document.createDocumentFragment();

    for (var number = 1; number <= total; number++) {
      var option = document.createElement('option');
      option.value = number;
      option.textContent = number;
      option.selected = number === current;
      options.appendChild(option);
    }

    select.textContent = '';
    select.appendChild(options);
    select.addEventListener('change', function () {
      window.location.href = pageUrl(select, parseInt(select.value, 10));
    });
  }

  function init() {
    document.querySelectorAll('select[data-forum-page-jump]').forEach(setUp);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
