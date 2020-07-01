$(document).ready(function () {
  $('.js-trigger-autosave-on-change').change(function () {
    
  });

  $('.js-move-event-to-top').click(function () {
    var event_container = $(this).closest('.timeline-event-container');
    var event_id = event_container.data('event-id');

    $.get(
      "/plan/move/timeline_events/" + event_id + "/top"
    ).done(function () {
      alert('success');

      // Move to top
      debugger;
    }).fail(function() {
      alert("Something went wrong and your change didn't save. Please try again.");
    });

  });

  $('#js-create-timeline-event').click(function () {
    var events_container = $('.timeline-events-container');
    var loading_indicator = $('.loading-indicator');

    // Indiate we're LOADING!
    loading_indicator.show();
    $('#js-create-timeline-event').attr('disabled', 'disabled');

    // TODO hit the endpoint to create an event
    $.post(
      "/plan/timeline_events",
      {
        "timeline_event": {
          "title": "Untitled Event",
          "timeline_id": events_container.data('timeline-id')
        }
      }
    ).done(function (data) {
      var new_event_id = data["id"];      
      var template = $('.timeline-event-template');
      var cloned_template = template.clone(true).removeClass('timeline-event-template');

      cloned_template.find('input[name="timeline_event[timeline_id]"]').val(new_event_id);
      cloned_template.appendTo(events_container);

      loading_indicator.hide();
      $('#js-create-timeline-event').removeAttr('disabled');

    }).fail(function () {
      alert('fail');

      loading_indicator.hide();
      $('#js-create-timeline-event').removeAttr('disabled');
    });

    // return false so we don't jump to the top of the page
    return false;
  });
})