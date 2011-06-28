checkCountry = false;
var setCountry = function() {
  if (checkCountry) {
    $.ajax({url: '/countries/get_code_for/'+escape($("#pod_url").val()), dataType: "json", success: function(json) {
      $("#pod_location option[value='"+json.location.code+"']").attr('selected', true);
    }, error: function () {}});
    checkCountry = false;
  }
}
var countryChecker = setInterval(setCountry, 2500)

$(document).ready(function() {
  $('#pod_url').keyup(function() {
    checkCountry = true;
  });
});

