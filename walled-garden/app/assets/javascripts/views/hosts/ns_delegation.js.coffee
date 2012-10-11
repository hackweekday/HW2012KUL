class Dnscell.Views.ns_delegation extends Backbone.View

  template: JST['hosts/ns_delegation']

  render: ->
    $(@el).html(@template(entries: "Entries goes here."))
    this