$(document).ready(function () {
  function get_event_id_from_url(url) {
    return url.split('/')[4];
  }

  $('.js-trigger-autosave-on-change').change(function () {
    $(this).closest('.autosave-form').submit();
    M.toast({
      html: "Autosaving..."
    });
  });

  $('.js-move-event-to-top').click(function () {
    var event_container = $(this).closest('.timeline-event-container');
    var event_id = event_container.data('event-id');

    $.get(
      "/plan/move/timeline_events/" + event_id + "/top"
    ).done(function () {
      // Move in the UI
      var event_id = get_event_id_from_url(this.url);
      var event_container = $('.timeline-events-container').find('.timeline-event-container[data-event-id="' + event_id + '"]');
      var events_list     = $('.timeline-events-container').find('.timeline-event-container');

      event_container.insertBefore(events_list[0]);
    }).fail(function() {
      alert("Something went wrong and your change didn't save. Please try again.");
    });

    return false;
  });

  $('.js-move-event-up').click(function () {
    var event_container = $(this).closest('.timeline-event-container');
    var event_id = event_container.data('event-id');

    $.get(
      "/plan/move/timeline_events/" + event_id + "/up"
    ).done(function () {
      // Move in the UI
      var event_id = get_event_id_from_url(this.url);
      var event_container = $('.timeline-events-container').find('.timeline-event-container[data-event-id="' + event_id + '"]');

      event_container.insertBefore(event_container.prev());
    }).fail(function() {
      alert("Something went wrong and your change didn't save. Please try again.");
    });

    return false;
  });

  $('.js-move-event-down').click(function () {
    var event_container = $(this).closest('.timeline-event-container');
    var event_id = event_container.data('event-id');

    $.get(
      "/plan/move/timeline_events/" + event_id + "/down"
    ).done(function () {
      // Move in the UI
      var event_id = get_event_id_from_url(this.url);
      var event_container = $('.timeline-events-container').find('.timeline-event-container[data-event-id="' + event_id + '"]');

      event_container.insertAfter(event_container.next());
    }).fail(function() {
      alert("Something went wrong and your change didn't save. Please try again.");
    });

    return false;
  });

  $('.js-move-event-to-bottom').click(function () {
    var event_container = $(this).closest('.timeline-event-container');
    var event_id = event_container.data('event-id');

    $.get(
      "/plan/move/timeline_events/" + event_id + "/bottom"
    ).done(function () {
      // Move in the UI
      var event_id = get_event_id_from_url(this.url);
      var event_container = $('.timeline-events-container').find('.timeline-event-container[data-event-id="' + event_id + '"]');
      var events_list     = $('.timeline-events-container').find('.timeline-event-container');

      event_container.insertAfter(events_list[events_list.length - 1]);
    }).fail(function() {
      alert("Something went wrong and your change didn't save. Please try again.");
    });

    return false;
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
      var template = $('.timeline-event-template > .timeline-event-container');
      var cloned_template = template.clone(true).removeClass('timeline-event-template');
      var timeline_id = cloned_template.find('.timeline-event-container').first().data('timeline-id');
      console.log('new event id = ' + new_event_id);
      console.log('timeline_id = ' + timeline_id);

      // Update IDs to the newly-created event
      cloned_template.data('event-id', new_event_id);
      cloned_template.attr('data-event-id', new_event_id);

      // Update labels to jump to this event's fields
      var title_field = cloned_template.find('.ref-title');
      title_field.find('input').attr('id', 'timeline-event-title-' + new_event_id);
      title_field.find('label').attr('for', 'timeline-event-title-' + new_event_id);

      var desc_field = cloned_template.find('.ref-description');
      desc_field.find('textarea').attr('id', 'timeline-event-description-' + new_event_id);
      desc_field.find('label').attr('for', 'timeline-event-description-' + new_event_id);

      var notes_field = cloned_template.find('.ref-notes');
      notes_field.find('textarea').attr('id', 'timeline-event-notes-' + new_event_id);
      notes_field.find('label').attr('for', 'timeline-event-notes-' + new_event_id);

      

      //cloned_template.find('input[name="timeline_event[timeline_id]"]').val(timeline_id);
      cloned_template.find('.js-delete-timeline-event').attr('href', '/plan/timeline_events/' + new_event_id);
      cloned_template.find('.autosave-form').attr('action', '/plan/timeline_events/' + new_event_id);

      cloned_template.appendTo(events_container);

      loading_indicator.hide();
      $('#js-create-timeline-event').removeAttr('disabled');

    }).fail(function () {
      alert('Error 292');

      loading_indicator.hide();
      $('#js-create-timeline-event').removeAttr('disabled');
    });

    // return false so we don't jump to the top of the page
    return false;
  });
});
