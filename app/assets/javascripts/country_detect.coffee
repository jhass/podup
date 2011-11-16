CountryChecker =
  disableSelect: ->
    $("#pod_location").prop("disabled", true)
  
  enableSelect: ->
    $("#pod_location").prop("disabled", false)
  
  disableSubmit: ->
    $("#pod_submit").prop("disabled", true)
  
  enableSubmit: ->
    $("#pod_submit").prop("disabled", false)
  
  lock: ->
    this.disableSelect()
    this.disableSubmit()
  
  release: ->
    this.enableSelect()
    this.enableSubmit()
  
  performCheck: ->
    value = $("#pod_url").val()
    if value
      this.lock()
      $.ajax( 
        url: "/countries/get_code_for/#{escape(value)}",
        dataType: "json",
        success: this.success,
        error: this.release
      )
  
  success: (json) ->
    option = $("#pod_location option").filter ->
      return this.value.match(new RegExp(json.location.code, "i"))
    option.attr('selected', true)
    CountryChecker.release()

$ ->
  CountryChecker.performCheck()
  $('#pod_url').focusout ->
    CountryChecker.performCheck()

