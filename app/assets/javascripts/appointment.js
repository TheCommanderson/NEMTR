var pos1, pos2

function initMap(start, dest) {
  // make sure the coords is received!
  console.log(start)
  console.log(dest)

  var directionsService = new google.maps.DirectionsService();
  var directionsRenderer = new google.maps.DirectionsRenderer();
  pos1 = new google.maps.LatLng(start[0], start[1]);
  pos2 = new google.maps.LatLng(dest[0], dest[1]);
  var mapOptions = {
    zoom: 14,
    center: pos1
  }
  var map = new google.maps.Map(document.getElementById('map'), mapOptions);
  var marker = new google.maps.Marker({
    position: pos1,
    map: map,
  });
  var marker2 = new google.maps.Marker({
    position: pos2,
    map: map,
  });
  directionsRenderer.setMap(map);
  directionsRenderer.setPanel(document.getElementById('right-panel'));
  calculateAndDisplayRoute(directionsService, directionsRenderer);
}

function calculateAndDisplayRoute(directionsService, directionsRenderer) {
  var start = pos1
  var end = pos2
  directionsService.route({
    origin: start,
    destination: end,
    travelMode: 'DRIVING'
  }, function(response, status) {
    if (status === 'OK') {
      console.log(response)
      // this is duration in seconds
      console.log(response.routes[0].legs[0].duration.value)
      directionsRenderer.setDirections(response);
    } else {
      window.alert('Directions request failed due to ' + status);
    }
  });
}