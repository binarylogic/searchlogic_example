jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept",
    "text/javascript")} 
})  

$(document).ready(function($) {
  // Change all select helpers to use ajax
  $('select.order_by, select.order_as, select.page, select.per_page').livequery(function() {
    var onchange = $(this).attr('onchange').toString();
    var matches = onchange.match(/window\.location = "(.*)" \+ this/);
    var url = matches[matches.length - 1];
    $(this).attr('onchange', null)
    $(this).change(function() {
      $('#users').load(url + $(this).val());
      return false;
    })
  })

  // Change all link helpers to use ajax
  $('a.order_by, a.order_as, a.page, a.per_page').livequery('click', function() {
    $('#users').load(this.href);
    return false;
  })

  // Change our search form to ajax
  $('#search_form').ajaxForm({target: '#users'});
})
    
  