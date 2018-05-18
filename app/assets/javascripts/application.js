// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require jquery.validate
//= require jquery.validate.localization/messages_es
//= require popper
//= require bootstrap-sprockets
//= require rails-ujs
//= require turbolinks
//= require_tree .

$(document).ready(function() {
  $('[data-js-hide-link]').click(function(event){
    $(this).parents('tr').fadeOut(1000);
    event.preventDefault(); 
  });



  $("#new_user").validate({
    rules: {
      "user[email]": {
        required: true,
        email: true
      },
      "user[password]": {
        required: true,
        minlength: 6
      },
      "user[password_confirmation]": {
        required: true,
        equalTo: "#user_password"
      }
    },
    messages: {
      mail: {
        required: "Email is required",
        email: "Please enter a valid email address"
      },
      password: {
        required: "Password is required",
        minlength: "Password must be more than 6"
      },
      password_confirmation: {
        required: "Password confirmation is required",
        equalTo: "Password and password confirmation must be same"
      }
    }
  });
});