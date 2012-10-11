class Dnscell.Views.user_api_token extends Backbone.View

  template: JST['user_settings/user_api_token']

  events: 
  	'click #regenerate_token': 'regenerateToken'

  render: =>
  	t = get_api_token()
  	$(@el).html(@template(user: @model, token: t.token))
  	this

  regenerateToken: (event) ->
    event.preventDefault
    #alert "google.com"
    regenerate_token = new Backbone.Collection()
    regenerate_token.url = '/api/users/regenerate_api_token'
    regenerate_token.fetch
      success: (data) =>
        t = get_api_token()
        $("#token").html(t.token)