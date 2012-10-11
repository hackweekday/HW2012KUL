class Dnscell.Routers.Users extends Backbone.Router
  routes: {
    ':id/setting': 'setting'
  }

  collection: null

  initialize: (id) ->
    @collection = new Dnscell.Collections.Domains()

  index: =>

  setting: (id) ->
    alert "setting #{id}"
    settingIndex = new Dnscell.Views.UsersIndex