//window.onload = function() {
document.addEventListener("turbolinks:load", function() {
 console.log("abstract append script is loaded");
  var saveBtn = document.getElementById("with_files_submit");
  if (saveBtn) {
    saveBtn.addEventListener('click', function () {
      abstract_fields = document.querySelectorAll('.abstract-text-field , .select_abstract');
      var n = 2;
      for (var i = 0; i < abstract_fields.length; i += n) {
        next_value = i+1;
        if (abstract_fields[i].value != "") {
            //abstract_fields[i].value += abstract_fields[next_value].value;
            //abstract_fields[next_value].parentNode.removeChild(abstract_fields[next_value]);
        } else {
            //abstract_fields[next_value].parentNode.removeChild(abstract_fields[next_value]);
        }
      } 
    });
  }
  // In your Javascript (external .js resource or <script> tag)
})
$(document).on('ready turbolinks:load', function() {
  console.log("Time to append the language values the abstract")
  $( "#with_files_submit" ).click(function() {
      alert( "Handler for .click() called." );
      // get all the select languages and their related 
      // abstract text areas and then append on submit
      $( "li.abstract-wrapper" ).each(function( index ) {
        console.log( index + ": " + $( this ).text() );
      });
  });

});



