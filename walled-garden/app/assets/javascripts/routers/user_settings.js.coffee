class Dnscell.Routers.UserSettings extends Backbone.Router
  routes: {
    'settings': 'settings'
  }

  collection: null

  settings: (id) ->
    @model = new Dnscell.Models.User($("#container").data('user'))
    usersettingView = new Dnscell.Views.UserSettingsIndex(model: @model)
    $("#container").html(usersettingView.render().el)

    settingContainer = new Dnscell.Views.user_profile(model: @model)
    $(".content_inside").html(settingContainer.render().el)
