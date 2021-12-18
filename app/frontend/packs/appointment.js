import Jquery from 'jquery'

function toggleView(sel){
    if (sel == 1){
      document.getElementById('show-dest-restricted').style.display = 'block';
      document.getElementById('show-pickup-restricted').style.display = 'none';
    }
    else if (sel == 2){
      document.getElementById('show-dest-restricted').style.display = 'none';
      document.getElementById('show-pickup-restricted').style.display = 'block';
    }
    else {
      document.getElementById('show-dest-restricted').style.display = 'none';
      document.getElementById('show-pickup-restricted').style.display = 'none';
    }
}

function checkFormTo() {
  var count = $('.checklist-to').filter(function() {
    return $(this).val() !== "";
  }).length;

  var total = $('.checklist-to').length;
  var checked = $('input[class=loc-select-to]:checked').length > 0;

  if (count == total && checked) {
    $('#submit-to').removeClass('disabled');
    $('#submit-to').removeAttr('disabled');
      } else {
    $('#submit-to').addClass('disabled');
    $('#submit-to').attr('disabled', 'disabled');
  }
  console.log(count + '/' + total);
}

function checkFormFrom() {
  var count = $('.checklist-from').filter(function() {
    return $(this).val() !== "";
  }).length;

  var total = $('.checklist-from').length;
  var checked = $('input[class=loc-select-from]:checked').length > 0;

  if (count == total && checked) {
    $('#submit-from').removeClass('disabled');
    $('#submit-from').removeAttr('disabled');
      } else {
    $('#submit-from').addClass('disabled');
    $('#submit-from').attr('disabled', 'disabled');
  }
  console.log(count + '/' + total);
}

$(document).ready(function() {
  $('#restrict_loc').change(function() {
      toggleView($('#restrict_loc').val());
    });
  $('.loc-select-to').change(function() {
      checkFormTo();
    });
  $('.loc-select-from').change(function() {
      checkFormFrom();
    });
  $(".checklist-to").keyup(function(){
    checkFormTo();
  });
  $(".checklist-from").keyup(function(){
    checkFormFrom();
  });
});
