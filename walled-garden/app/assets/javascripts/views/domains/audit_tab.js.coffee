class Dnscell.Views.audit_tab extends Backbone.View
  template: JST['domains/audit_tab']

  #initialize: ->
    #@options.audits.on('reset', @render, this)

  render: ->
    $(@el).html(@template(zone: @options.zone, host: @options.host, audit: @options.audit, audits: @options.audits))
    this