class Dnscell.Views.change_password extends Backbone.View

  template: JST['user_settings/change_password']

  render: ->
  	$(@el).html(@template(user: @model, password_length: @options.password_length))
  	# alert @options.password_length
  	this

  events:
    "click .close":"close"
    "submit":"do_change_password"

  close: (e) ->
    e.preventDefault()
    $("#modal").modal("hide")

  do_change_password: (e) ->
    e.preventDefault()
    attributes =
    	user:
        current_password: $("#user_current_password").val()
        password: $("#user_password").val()
        password_confirmation: $("#user_password_confirmation").val()
     
    user = new Backbone.Model()
    user.url = "/api/users/change_password"
    user.save attributes,
      success: =>
        $("#modal").modal("hide")
        show_notice("Pasword changed.")

      error: (entry, response) =>
        handleError(entry, response)