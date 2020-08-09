
require("jquery")
// console.log("loading common core...")

// require("jstimezonedetect/dist/jstz.min")
// var JSTZ = require('jstimezonedetect');




$(document).on('turbolinks:load', function() {

  $(document).ready(() => {
    var user_timezone = '';
    try {user_timezone = JSTZ.determine().name();} catch(e){}
    // always pass csrf tokens on ajax calls


    // $.ajaxSetup({
    //   beforeSend: (xhr) => {
    //
    //     xhr.setRequestHeader('X-CSRF-Token',  $('meta[name="csrf-token"]').attr('content'))
    //     xhr.setRequestHeader( 'X-User-Timezone', user_timezone)
    //
    //
    //   }
    // })

    $("body").on("click", "[data-role='close-button']", (event) => {
      var form_name;
      form_name = $(event.currentTarget).data("name");
      row_id = $(event.currentTarget).data("row-id");

      if (row_id) {
        $("table." + form_name + "-table tr[data-id=" + row_id + "][data-edit='true']").remove()
        $("table." + form_name + "-table tr[data-id=" + row_id + "]:not([data-edit='true'])").fadeIn()
        $("table." + form_name + "-table tr[data-id=" + row_id + "]:not([data-edit='true']) .show-area").show()
      } else {
        if ($(".new-" + form_name + "-form").length == 0) {
          throw("ERROR: not found" + "  .new-" + form_name + "-form")
        }
        var $form = $(event.currentTarget).closest(".new-" + form_name + "-form")
        $form.slideUp()
        $form.siblings(".new-" + form_name + "-button").fadeIn()
        $form.find("i").remove()
      }
    })
  });
});



