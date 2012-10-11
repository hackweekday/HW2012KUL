class Dnscell.Views.MxForm extends Backbone.View

  template: JST['domains/host/record/mx_form']

  events:
    'submit':'createRecord'
    'click .cancel_dialog':'closeForm'

  render: ->
    # console.log @model
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
      content: [$("#record_priority").val(), $("#record_content").val()].join(" ")
      mx_host: $("#record_content").val()
      ttl: $("#record_ttl").val()
      priority: $("#record_priority").val()
      record_host: $("#domain_combine").val()
    record.save attributes,
      wait: true
      success: (model, response) ->
        console.log 'model'
        console.log model
        console.log 'response'
        console.log response
        #get_mxs_count($("#record_host_id").val())
        unless $("#record_data").data('record')
          mx_count = Number( $(".mx_count").text() ) + 1
          $("#mx_count").val( mx_count )
          $(".mx_count").html( mx_count )
        $("#record_form").modal("hide")
        console.log record
        if type == 'create'
          # update_record_count()
          add_rr_row(record)
        else
          update_rr_row(record)

      error: (entry, response) =>
        handleError(entry, response)