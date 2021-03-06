class Dnscell.Views.AForm extends Backbone.View

  template: JST['domains/host/record/a_form']

  initialize: ->
    # @model.on('all', @removeDomain, this)

  removeDomain: ->
    alert 'event'

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
      content: $("#record_content").val()
      ttl: $("#record_ttl").val()
      record_host: $("#domain_combine").val()
    record.save attributes,
      wait: true
      success: (data) =>
        if type == 'create'
          update_record_count()
          add_rr_row(record)
        else
          update_rr_row(record)

      error: (entry, response) =>
        handleError(entry, response)