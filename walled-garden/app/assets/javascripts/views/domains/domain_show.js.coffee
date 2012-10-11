class Dnscell.Views.DomainShow extends Backbone.View
  template: JST['domains/domain_show']

  initialize: ->
    @model.on('reset', @render, this)
    @model.on('delete', @removeDomain, this)
    @z = new Dnscell.Models.Zone( $("#zone_data").data('zone') )
    @h = new Dnscell.Models.Host( $("#zone_data").data('host') )
    

  events:
    'click .delete': 'deleteDomain'
    'click .hosts_tab': 'hosts_tab'
    'click .ns_tab': 'ns_tab'
    'click .dashboard_tab': 'dashboard_tab'
    'click .audit_tab': 'audit_tab'
    'click .share_tab':'share_tab'
    'click .dnssec_tab': 'dnssec_tab'
    'click .graph_tab': 'graph_tab'
    'click .assign_tab':'assign_tab'

  render: ->
    #alert 'DomainShow'
    #alert @model.get('id')
    # console.log @model
    $(@el).attr('id', "domain_#{@model.get('id')}" ).html(@template(domain: @model, zone: @z))
    #$("#domain_top").html(@template(domain: @model))
    #$("#domain_id").attr("id","domain_#{@model.get('combine')}");
    $("#domain_top").html($(@el).attr('id', "domain_#{@model.get('id')}" ).html(@template(domain: @model)))
    #get_host_count(@model) #guna counter...
    this

  deleteDomain: (event) ->
  	console.log @model
  	event.preventDefault()
  	if confirm("Are you sure?")
	  	if @model.get('zone_name')
        #console.log 'atas'
        @model = new Dnscell.Models.Domain(id: domain2url(@model.get('zone_name')))
	  	else
        #console.log 'bawah'
        @model = new Dnscell.Models.Domain(id: domain2url(@model.get('reference1')))
	  	@model.destroy
        #async: false
	  		success: ->
	  			# Backbone.history.navigate("apps_management/domains" , true)

			    zoneFirst = new Backbone.Model
			    zoneFirst.url = '/api/zones/first'
			    zoneFirst.fetch #({
			      success: ->
              if typeof zoneFirst.get('combine') == "undefined"
                window.location = '/apps_management/domains/new'
			          # Backbone.history.navigate("apps_management/domains/new", true)
              else
                Backbone.history.navigate("apps_management/domains/#{zoneFirst.get('combine')}".replace(/\./g, '_') , true)
                $('#current_domains_count').html(parseInt($('#current_domains_count').text()) - 1 ) 
                show_notice("Domain deleted.")
			      #})
        #error: alert "p"

  removeDomain: ->
  	alert 'removed!'

  selectTab: (event) ->
    # event.preventDefault()
  	$('.dash_tab').removeClass('selected')
  	@$('.dash_tab').addClass('selected')
  	event.preventDefault()

  hosts_tab: (event) ->
    @select_tab(event)
    id = domain2url(@model.get('combine'))
    $("#dttb_host").val(@model.get('combine'))
    hostsView = new Dnscell.Views.Hosts
    $("#sub_container").html(hostsView.render().el)
    render_hosts_dttb(domain2url($("#current_domain").html()))
    $("#tab_state").val("hosts_tab")

  ns_tab: (event) ->
    @select_tab(event)
    event.preventDefault()
    nservers = new Backbone.Collection()
    nservers.url = '/api/zones/' + @z.get('id') + '/fetch_vanity_name_servers'
    nservers.fetch
      success: =>
      ns_tab_view = new Dnscell.Views.ns_tab(zone: @z, nameservers: nservers)
      $(".content_inside").html(ns_tab_view.render().el)
      $("#tab_state").val("ns_tab")

  dashboard_tab: (event) ->
    @select_tab(event)
    dashView = new Dnscell.Views.Dashboard(domain: @model, zone: @z, info: dashboard_info(@model.get('combine')))
    $(".content_inside").html(dashView.render().el)
    $("#tab_state").val("dashboard_tab")

  assign_tab: (event) ->
    @select_tab(event)
    scopes = new Dnscell.Collections.UserScopeAssigns()
    scopes.fetch
      data: { id: domain2url($("#zone_data").data('zone').zone_name) }
      success: =>
        assign_tab_view = new Dnscell.Views.assign_tab(zone: @z, scopes: scopes)
        $(".content_inside").html(assign_tab_view.render().el)
        #Dnscell.Views.share_tab.prototype.render_assign_tab_content()
    $("#tab_state").val("assign_tab")

  audit_tab: (e) ->
    @select_tab(e)
    audit = audit_plan(@z.get('zone_name'))
    @audits = ""
    unless audit.status
      audits_f = new Backbone.Collection()
      audits_f.url = '/top_audits?ref=' + @h.get('reference1')
      audits_f.fetch
        async: false
        success: =>      
          @audits =  audits_f
    #alert @audits[0].get('user_id')
    audit_tab_view = new Dnscell.Views.audit_tab(zone: @z, host: @h, audit: audit, audits: @audits)
    $(".content_inside").html( audit_tab_view.render().el )
    if audit.status
      render_audit_dttb(@h.get('reference1'))
      
  share_tab: (e) ->
    @select_tab(e)
    scopes = new Dnscell.Collections.Scopes()
    scopes.fetch
      data: { zone_id: $("#zone_data").data('zone').id }
      success: =>
        share_tab_view = new Dnscell.Views.share_tab(zone: @z, host: @h, scopes: scopes)
        $(".content_inside").html( share_tab_view.render().el )
        Dnscell.Views.share_tab.prototype.render_share_tab_content()
    $("#tab_state").val("share_tab")

  dnssec_tab: (e) ->
    e.preventDefault()
    if $("ul.domain_tab a.dash_tab.selected").text() != "DNSSEC"
      @select_tab(e)
      dnssec_tab_view = new Dnscell.Views.dnssec_tab(zone: @z, host: @h)
      $(".content_inside").html( dnssec_tab_view.render().el )
      $("#tab_state").val("dnssec_tab")
      #$("ul.domain_tab a.dash_tab.selected").css('cursor','default')
    else
      @select_tab(e)
    #$(this.el).undelegate('.dnssec_tab', 'click');

  graph_tab: (e) ->
    @select_tab(e)
    graph_tab_view = new Dnscell.Views.graph_tab(zone: @z, host: @h)
    $(".content_inside").html( graph_tab_view.render().el )
    $("#tab_state").val("graph_tab")
     # Create and populate the data table.
    $('#graph_date').datepicker
      dateFormat: "yy-mm-dd"
      changeMonth: true
      changeYear: true
      onSelect: ->
        Dnscell.Views.graph_tab.prototype.render_graph()
    $(".graph_item").hide()
    $(".graph_item:first").show()
    Dnscell.Views.graph_tab.prototype.render_graph()

  select_tab: (e) ->
    e.preventDefault()
    $('.dash_tab').removeClass('selected')
    $(e.currentTarget).addClass('selected')
