class Dnscell.Views.SrvForm extends Backbone.View

  template: JST['domains/host/record/srv_form']

  events:
    'submit':'createRecord'
    'click .cancel_dialog':'closeForm'

  render: ->
    $(@el).html(@template(host: @model, zone_default_ttl: @options.zone_default_ttl , record: @options.record))
    this

  closeForm: ->
    $("#record_form").modal("hide")

  createRecord: (event) =>
    event.preventDefault()
    if $("#record_data").data('record')
      record = new Dnscell.Models.Record( $("#record_data").data('record') )
      type = 'update'
    else
      record = new Dnscell.Models.Record( )
      type = 'create'
    attributes =
      host_id: $("#record_host_id").val()
      record_type: $("#record_rr_type").val()
      target: $("#record_target").val()
      ttl: $("#record_ttl").val()
      record_host: $("#domain_combine").val()
      content: [$("#record_priority").val(), $("#record_weight").val(), $("#record_port").val(), $("#record_target").val()].join(' ')
      port: $("#record_port").val()
      priority: $("#record_priority").val()
      weight: $("#record_weight").val()
    record.save attributes,
      wait: true
      success: ->
        if type == 'create'
          update_record_count()
          add_rr_row(record)
        else
          update_rr_row(record)
      error: (entry, response) =>
        handleError(entry, response)