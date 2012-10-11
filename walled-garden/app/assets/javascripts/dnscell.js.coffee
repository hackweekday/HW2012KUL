window.Dnscell =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    new Dnscell.Routers.Domains()
    Backbone.history.start(pushState: true)

$(document).ready ->
  Dnscell.init()
