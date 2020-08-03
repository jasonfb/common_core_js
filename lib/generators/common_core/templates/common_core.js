
require("jquery")
console.log("loading common core...")

$(function(){
  // always pass csrf tokens on ajax calls
  $.ajaxSetup({
    headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') }
  });
});

$(document).on('turbolinks:load', function() {
  $(document).ready(() => {
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
  })
});



