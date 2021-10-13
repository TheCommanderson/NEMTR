// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import "channels"
import '../js/bootstrap_js_files.js'
import Logo from 'images/logo'
import Jquery from 'jquery'
import 'inputmask'

Rails.start()
Turbolinks.start()

$(document).on('turbolinks:load', function () {
  var im = new Inputmask('(999) 999 9999');
  var selector = $('.phone-form');
  im.mask(selector);

  var im = new Inputmask('99999');
  var selector = $('.zip-form');
  im.mask(selector);

  var im = new Inputmask('AA');
  var selector = $('.state-form');
  im.mask(selector);

  var im = new Inputmask('A|9[A|9]{1,6}');
  var selector = $('.license-plate-form');
  im.mask(selector);
});
