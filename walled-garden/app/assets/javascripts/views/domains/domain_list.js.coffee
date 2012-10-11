class Dnscell.Views.DomainList extends Backbone.View
  tagName: 'li'
  id: 'domain'

  template: JST['domains/domain']

  render: ->
    render: ->
    $(@el).html(@template(entry: @model))
    this