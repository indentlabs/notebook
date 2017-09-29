$(document).ready(function () {
  // mixpanel.track(
  //     "test",
  //     {
  //       "foo": "bar"
  //     }
  // );

  $('.recent-activity').find('a.js-edit-hover').click(function (link) {
    mixpanel.track("clicked recent activity edit link", {});
  });

  $('.recent-activity').find('a:not(.js-edit-hover)').click(function (link) {
    mixpanel.track("clicked recent activity show link", {});
  });

  $('.content-question-submit').click(function (link) {
    mixpanel.track("answered serendipitous question", {});
  });

  $('.expand').click(function (link) {
    mixpanel.track("clicked expand-all on content");
  });

  $('.share').click(function (link) {
    mixpanel.track("clicked share link");
  });

  $('.universes-lock a').click(function (link) {
    mixpanel.track("clicked universe lock link");
  });

  $('.mp-sidebar-save').click(function (link) {
    mixpanel.track('A/B 1a: clicked sidebar save')
  });

  $('.mp-fab-save').click(function (link) {
    mixpanel.track('A/B 1b: clicked fab save');
  });

});
