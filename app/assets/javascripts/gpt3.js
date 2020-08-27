$(document).ready(function () {
  $('#suggestions').hide();
  $('#progress-bar').hide();
  $('#progress-text').hide();

  $('#mental-unblocker, .regenerate-suggestions').click(function () {
    $('.suggestions').hide();

    // Get the most-recent 1000 words
    var words_to_include = 1000;
    var document_id      = 6;
    var full_prompt      = $('#editor').first().html()
                            .split("</p><p>").join("\n\n")
                            .split("<p>").join("")
                            .split("</p>").join("")
                            .trim();
    var word_count       = full_prompt.split(' ').length;
    var truncated_prompt = full_prompt.split(' ').slice(Math.max(word_count - words_to_include, 0)).join(' ');

    $('#mental-unblocker').hide();
    $('#progress-bar').show();
    $('#progress-text').show();

    $.post("/documents/" + document_id + "/continuation", {
      prompt: truncated_prompt
    }).done(function(suggestions) {

      $('.suggestions').show();
      $('#progress-bar').hide();
      $('#progress-text').hide();

      console.log("Suggestions: ");
      console.log(suggestions);

      var suggestion_containers = $('.suggestion');
      suggestions.forEach(function (suggestion, index) {
        var reformatted_suggestion = suggestion//.trim()
          .split("\n\n").join("</p><p>")
          .split("\n").join("</p></p>")
          .split("”“").join("\"<br />\"");
        $(suggestion_containers[index]).html("<p>" + reformatted_suggestion + "</p>");

      });

      // $([document.documentElement, document.body]).animate({
      //   scrollTop: $(".suggestions").offset().top
      // }, 2000);
    }).fail(function(error) {
      $('#progress-bar').hide();
      $('#progress-text').hide();
      $('#mental-unblocker').show();
    });

    return false;
  });

  $('.use-suggestion').click(function () {
    // Instead of just directly concatenating the suggestion HTML onto $('#editor'), we
    // want to instead take a two-step approach to ensure we can continue on mid-sentence:

    // 1. Append the first <p> text in the suggestion to the last <p> in the editor
    var leading_text = $(this).closest('.suggestion-card')
                              .find('.suggestion')
                              .find('p')
                              .first()
                              .html();
    var final_p = $('#editor').find('p:last');
    final_p.html(final_p.html() + leading_text);

    // 2. Append the rest of the suggestion with new <p> tags in the editor
    var following_ps = $(this).closest('.suggestion-card')
                                .find('.suggestion')
                                .find('p:not(:first)');
    $('#editor').append(following_ps);

    // Clear out existing suggestions
    $('.suggestion').text('');
    $('.suggestions').hide();
    $('#mental-unblocker').show();

    // Trigger an autosave of the document
    window.autosave();

    return false;
  });

  $('.clear-suggestions').click(function () {
    // Clear out existing suggestions
    $('.suggestion').text('');
    $('.suggestions').hide();
    $('#mental-unblocker').show();

    return false;
  });
});
