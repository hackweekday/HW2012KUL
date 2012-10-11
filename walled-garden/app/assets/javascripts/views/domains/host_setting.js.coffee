class Dnscell.Views.HostSetting extends Backbone.View

  template: JST['domains/host_setting']

  events:
    # 'click .type_list>li>a':"check_cname"
    'click .txt_btn':'txt_btn'
    'click .cname_btn':'cname_btn'
    'click .a_btn':'a_form'
    'click .aaaa_btn':'aaaa_form'
    'click .srv_btn':'srv_form'
    'click #check_all_record':'CheckAllRecord'
    'click .delete_record':'delete_record'
    'click .edit_icon':'edit_icon'
    'click .delete_icon':'delete_icon'

          # show_error "Already have CNAME in a record. Cannot add any other record anymore."
          # throw new Error('Stop here.')
  delete_icon: (e) ->
    e.preventDefault()
    $(e.currentTarget).closest("tr").find("input[type=checkbox]").attr("checked", true)
    $(".delete_record").click()

  edit_icon: (e) ->
    e.preventDefault()
    record = new Dnscell.Models.Record( $(e.currentTarget).closest('tr').find('.record_data').data('record') )
    switch record.get('record_type')
      when "A"
        form = new Dnscell.Views.AForm( model: @model, zone_default_ttl: @options.zone_default_ttl , record: record )
      when "AAAA"
        form = new Dnscell.Views.AaaaForm( model: @model, zone_default_ttl: @options.zone_default_ttl , record: record )
      when "TXT"
        form = new Dnscell.Views.TxtForm( model: @model, zone_default_ttl: @options.zone_default_ttl , record: record )
      when "CNAME"
        form = new Dnscell.Views.CnameForm( model: @model, zone_default_ttl: @options.zone_default_ttl , record: record )
      when "SRV"
        form = new Dnscell.Views.SrvForm( model: @model, zone_default_ttl: @options.zone_default_ttl , record: record )
        
    $("#record_form").html(form.render().el)
    $("#record_form").modal()


  initialize: ->
    # console.log "HostSetting initialize. model:"
    # console.log @model

  CheckAllRecord: (e) ->
    if $(e.currentTarget).is(':checked')
      $.each($("input[name^=delete_record]:not([read-only=true])"), -> $(this).prop("checked", true) )
    else
      $.each($("input[name^=delete_record]:not([read-only=true])"), -> $(this).prop("checked", false) )

  render: ->
    $(@el).html(@template(records: @collection, host: @model))
    @collection.each(@appendEntry)
    # $(@el).html(@template(records: @collection))

    this

  appendEntry: (record) =>
    rView = new Dnscell.Views.RecordOneRow(model: record)
    @$(".rr_loop").append(rView.render().el)
    # console.log record
    # $("#rr_data_" + record.get('id')).data('record', record.toJSON() )
    # console.log $("#rr_data_" + record.get('id')).data('record')
    # console.log $("#rr_data_" + record.get('id'))

  a_form: (e) ->
    e.preventDefault()
    if check_cname(@model)
    else
      aForm = new Dnscell.Views.AForm(model: @model, zone_default_ttl: $("#zone_data").data('zone').zone_default_ttl , record: '')
      $("#record_form").html(aForm.render().el)
      $("#record_form").modal()

  aaaa_form: (e) ->
    e.preventDefault()
    if check_cname(@model)
    else
      aForm = new Dnscell.Views.AaaaForm(model: @model, zone_default_ttl: $("#zone_data").data('zone').zone_default_ttl)
      $("#record_form").html(aForm.render().el)
      $("#record_form").modal()

  txt_btn: (e) ->
    e.preventDefault()
    if check_cname(@model)
    else
      aForm = new Dnscell.Views.TxtForm(model: @model, zone_default_ttl: $("#zone_data").data('zone').zone_default_ttl)
      $("#record_form").html(aForm.render().el)
      $("#record_form").modal()

  srv_form: (e) ->
    e.preventDefault()
    if check_cname(@model)
    else
      srvForm = new Dnscell.Views.SrvForm(model: @model, zone_default_ttl: $("#zone_data").data('zone').zone_default_ttl)
      $("#record_form").html(srvForm.render().el)
      $("#record_form").modal()

  cname_btn: (e) ->
    e.preventDefault()
    if check_have_record(@model)
    # if check_cname(@model)
      show_error "Cannot add CNAME. Record is not empty."
    else
      aForm = new Dnscell.Views.CnameForm(model: @model, zone_default_ttl: $("#zone_data").data('zone').zone_default_ttl)
      $("#record_form").html(aForm.render().el)
      $("#record_form").modal()

  delete_record: (e) =>
    e.preventDefault()
    if $("input[name^=delete_record]:checked").serialize().length > 0
      if confirm "Are you sure?"
        record_ids = ""
        _.each($("input[name^=delete_record]:checked"), (x) -> record_ids += $(x).val().replace("rr_", "") + "," )
        records = new Dnscell.Models.Record({id: "[#{record_ids}]" })
        records.destroy({
          success: =>
            #get_record_count(@model.get('id'))
            records_count = Number( $(".record_count").text() ) - Number( $(".rr_loop input:checked").length )
            $(".record_count").text( records_count )
            $("#record_count").val( records_count )
            $("input[name^=delete_record]:checked").closest("tr").remove()
            show_notice "Record deleted."
            update_zebra_table()
            if $(".rr_loop > tr").length == 2
              $(".no_record_tr").show()
              # $(".rr_loop").html("<tr class='no_record_tr'><td colspan='6'>No Record</td></tr>")
        	})