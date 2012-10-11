class Dnscell.Views.MailExchange extends Backbone.View

  template: JST['domains/mail_exchange']

  events:
    'click #add_mx':'add_mx_form'
    'click #check_all_record':'CheckAllRecord'
    'click .delete_record':'delete_record'
    'click .edit_icon':'edit_icon'

  edit_icon: (e) ->
    e.preventDefault()
    record = new Dnscell.Models.Record( $(e.currentTarget).closest('tr').find('.record_data').data('record') )
    #alert record.get("content")
    mxformView = new Dnscell.Views.MxForm(model: @model, zone_default_ttl: $("#zone_data").data('zone').zone_default_ttl, record: record )
    $("#record_form").html(mxformView.render().el)
    $("#record_form").modal()

  initialize: ->
    console.log "MailExchange initialize. model:"
    console.log @model

  CheckAllRecord: (e) ->
    if $(e.currentTarget).is(':checked')
      $.each($("input[name^=delete_record]"), -> $(this).prop("checked", true) )
    else
      $.each($("input[name^=delete_record]"), -> $(this).prop("checked", false) )

  render: ->
    if @collection.length > 0
      $(".no_record_tr").hide()
    $(@el).html(@template(records: @collection))
    @collection.each(@appendEntry)
    # $(@el).html(@template(records: @collection))
    this

  appendEntry: (record) =>
    rView = new Dnscell.Views.RecordOneRow(model: record)
    @$(".rr_loop").append(rView.render().el)

  add_mx_form: (e) ->
  	# console.log(@model)
    if check_cname(@model)
      show_error("Unable to add MX. CNAME already exist")
    else
      mxformView = new Dnscell.Views.MxForm(model: @model, zone_default_ttl: $("#zone_data").data('zone').zone_default_ttl)
      $("#record_form").html(mxformView.render().el)
      $("#record_form").modal()

  delete_record: (e) ->
    e.preventDefault()
    if $("input[name^=delete_record]:checked").serialize().length > 0
      if confirm "Are you sure?"
        record_ids = ""
        _.each($("input[name^=delete_record]:checked"), (x) -> record_ids += $(x).val().replace("rr_", "") + "," )
        records = new Dnscell.Models.Record({id: "[#{record_ids}]" })
        records.destroy({
          success: =>
            #get_mxs_count(@model.get('id'))
            mx_count = Number( $(".mx_count").text() ) - Number( $("input[name^=delete_record]:checked").length )
            $(".mx_count").text( mx_count )
            $("#mx_count").val( mx_count )
            $("input[name^=delete_record]:checked").closest("tr").remove()
            show_notice "Record deleted."
            if $(".rr_loop > tr").length == 2
              $(".no_record_tr").show()
        	})