class Dnscell.Views.Host extends Backbone.View
  template: JST['domains/host']

  events: ->
    "click .host_settings_tab":"host_settings_tab"
    "click .mail_exchanger_tab":"mail_exchanger_tab"
    "click .services_tab":"services_tab"
    "click .done":"done"
    "click .add_record": "add_record"

  render: ->
    $(@el).html(@template(host: @model))
    this

  host_settings_tab: (e) =>
    # host = new Backbone.Model
    # host.url = '/api/hosts/find_by_combine?combine=' + domain2url($("#host").val())
    # host.fetch({
    #   success: ->
    #     console.log(host)
    #     hostView = new Dnscell.Views.Host({model: host})
    #     $("#manage_host").html(hostView.render().el)
    #     show_manage_host()
    #     records = new Dnscell.Collections.Records
    #     records.url = "/api/records?host_id=" + @model.get('id')
    #     records.fetch({
    #     success: ->
    #       hostsettingView = new Dnscell.Views.HostSetting(model: @model, collection: records)
    #       $(".modal-body").html(hostsettingView.render().el)
    #     })
    # })
    hostView = new Dnscell.Views.Host({model: @model})
    $("#manage_host").html(hostView.render().el)
    show_manage_host()
    switch @model.get('service')
      when 1
        get_record_count(@model.get('id'))
        records = new Dnscell.Collections.Records
        records.url = "/api/records?host_id=" + @model.get('id')

        #OK
        host = @model

        records.fetch({
        success: ->
          @$(".rr_loop").html("") if records.length > 0
          hostsettingView = new Dnscell.Views.HostSetting(model: host, collection: records)
          $("#manage_host .modal-body").html(hostsettingView.render().el)
          update_zebra_table()
          if records.length > 0
            @$(".no_record_tr").hide()
        })
        $(".record_count").html($("#record_count").val())
      when 2
        $("#manage_host .record_count").hide()
        forward = new Backbone.Model()
        forward.url = '/api/hosts/get_forward?host_id=' + @model.get('id')
        forward.fetch
          success: ->
            forwardView = new Dnscell.Views.domain_forwarding(model: forward)
            $("#manage_host .modal-body").html(forwardView.render().el)
      when 3
        $("#manage_host .record_count").hide()
        dynamic_dns = new Backbone.Model()
        dynamic_dns.url = '/api/hosts/get_dynamic_dns?host_id=' + @model.get('id')
        dynamic_dns.fetch
          success: ->
            dynamicView = new Dnscell.Views.dynamic_dns(model: dynamic_dns)
            $("#manage_host .modal-body").html(dynamicView.render().el)
            if $("#dyn_current_ip").val().length == 0
              $("#dyn_current_ip").val($("#client_ip").val())
      when 4
        sView = new Dnscell.Views.short_urls(model: @model)
        $("#manage_host .modal-body").html(sView.render().el)
        # $("#shorturl").dataTable() # render_shorturl_dttb
        render_shorturl_dttb(@model.get('id'))
      when 5
        $("#manage_host .record_count").hide()
        $("#manage_host .mail_exchanger_tab").hide()
        nsDelegationView = new Dnscell.Views.ns_delegation()
        $("#manage_host .modal-body").html(nsDelegationView.render().el)
        #get_record_count(@model.get('id'))
        #get_mxs_count(@model.get('id'))
    $(".mx_count").html( $("#mx_count").val() )
    e.preventDefault()

  mail_exchanger_tab: (e) =>
    $(".host_tab").removeClass("selected")
    $(".mail_exchanger_tab").addClass("selected")
    mx_records = new Dnscell.Collections.MxRecords()
    mx_records.url = "/api/records/mxs?host_id=" + @model.get('id')
    host = @model
    console.log "x1"
    mx_records.fetch({
      success: ->
        @$(".rr_loop").html("") if mx_records.length > 0
        mailexchangeView = new Dnscell.Views.MailExchange(model: host, collection: mx_records)
        $("#manage_host .modal-body").html(mailexchangeView.render().el)
        update_zebra_table()
        if mx_records.length > 0
          @$(".no_record_tr").hide()
        # show_manage_host()
      })
    $(".mx_count").html( $("#mx_count").val() )
    e.preventDefault()

  services_tab: (e) ->
    $(".host_tab").removeClass("selected")
    $(".services_tab").addClass("selected")
    $(".modal-body").hide()
    $("#services_tab").show()
    e.preventDefault()

  done: (e) ->
    e.preventDefault()
    $("#manage_host").modal('hide')

  add_record: (e) =>
  	e.preventDefault()
  	@$(".type_list, .arrow_up").toggle()
