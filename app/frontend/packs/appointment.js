import Jquery from 'jquery'

function initMap(start, dest) {
  // make sure the coords is received!
  // console.log(start)
  // console.log(dest)

  var directionsService = new google.maps.DirectionsService();
  var directionsRenderer = new google.maps.DirectionsRenderer();
  var pos1 = new google.maps.LatLng(start[0], start[1]);
  var pos2 = new google.maps.LatLng(dest[0], dest[1]);
  var mapOptions = {
    zoom: 14,
    center: pos1
  }
  var map = new google.maps.Map(document.getElementById('map'), mapOptions);
  directionsRenderer.setMap(map);
  directionsRenderer.setPanel(document.getElementById('right-panel'));
  calculateAndDisplayRoute(directionsService, directionsRenderer, pos1, pos2);
}

function calculateAndDisplayRoute(directionsService, directionsRenderer, start, end) {
  directionsService.route({
    origin: start,
    destination: end,
    travelMode: 'DRIVING'
  }, function(response, status) {
    if (status === 'OK') {
      // console.log(response)
      // this is duration in seconds
      console.log(response.routes[0].legs[0].duration.value)
      var est = response.routes[0].legs[0].duration.value
      directionsRenderer.setDirections(response);
    } else {
      window.alert('Directions request failed due to ' + status);
    }
  });
}

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
