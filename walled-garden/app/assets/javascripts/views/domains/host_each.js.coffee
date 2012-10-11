class Dnscell.Views.HostEach extends Backbone.View

  tagName: 'tr'

  template: JST['domains/HostEach']

  render: ->
    #alert @model.get('combine')
    #alert 'domain ' + domain.get('combine')
    #$(@el).html(@template(entry: @model))
    $(@el).html(@template(host: @model))
    this
