class Dnscell.Views.DomainsIndex extends Backbone.View
  template: JST['domains/index']

  initialize: ->
    @collection.on('reset', @render, this)
    @collection.on('add', @appendEntry, this)

  render: ->
    #$(@el).html(@template())
    @collection.each(@appendZone)
    this
    
  appendZone: (domain) =>
    view = new Dnscell.Views.Domain(model: domain)
    $('#domains').append(view.render().el)