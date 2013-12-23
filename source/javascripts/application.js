//= require ./vendor/jquery
//= require_tree .

$(function(){
  $('.thumbnails a[class!=quicktime]').fancybox({
    overlayOpacity: 0.8,
    overlayColor: '#111',
    zoomSpeedChange: 100,
    padding: 0
  });

  $('[placeholder]').focus(function() {
    var input = $(this);
    if (input.val() == input.attr('placeholder')) {
      input.val('');
      input.removeClass('placeholder');
    }
  }).blur(function() {
    var input = $(this);
    if (input.val() == '' || input.val() == input.attr('placeholder')) {
      input.addClass('placeholder');
      input.val(input.attr('placeholder'));
    }
  }).blur().parents('form').submit(function() {
    $(this).find('[placeholder]').each(function() {
      var input = $(this);
      if (input.val() == input.attr('placeholder')) {
        input.val('');
      }
    })
  });

  var email = ['andre', 'cantarel.de'].join('@');
  $('#email').html(email).attr('href', 'mailto:' + email);

  $.gaTracker('UA-20691819-1');

  if ($('.blog-posts').length) {
    $(window).scroll(function() {
      var hash = '#' + $('.blog-posts li:in-viewport:first').attr('id');
      if (location.hash != hash) {
        history.replaceState('', '', hash);
      }
    });
  }
});


