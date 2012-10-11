class Dnscell.Views.RecordOneRow extends Backbone.View
  tagName: 'tr'

  template: JST['domains/host/record/one_row']

  initialize: ->
    @model.on('all', @removeDomain, this)

  removeDomain: ->
  	alert 'event'

  render: ->
    $(@el).attr('id', "rr_#{@model.get('id')}" ).html(@template(record: @model))
    this