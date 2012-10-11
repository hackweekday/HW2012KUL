class Dnscell.Views.Dashboard extends Backbone.View
  template: JST['domains/dashboard/dashboard']

  render: ->
    $(@el).html(@template(domain: @options.domain, zone: @options.zone, info: @options.info))
    this

  initialize: ->
  	# console.log @model
    @load_initial()

  events:
    "click .recheck":"recheck"
    'click .btn_minigraf>li':'graph_selector'
    #'click .btn_minigraf':'render_graph'

  load_initial: ->
    #if @options.domain.get('subdomain') is "@"
    $(".btn_minigraf li").first().addClass("current")
    @render_graph()

  graph_selector: (e) ->
    e.preventDefault()
    index = $(".btn_minigraf > li").index(e.currentTarget)
    $(".btn_minigraf > li").removeClass("current")
    $(".mini_graph").hide()
    $(".mini_graph:eq(#{index})").show()
    $(".btn_minigraf > li:eq(#{index})").addClass("current")
    switch index
      when 0
        @render_graph()
        #console.log '1'
      when 1
        @render_graph2()

  render_graph: ->
    t = get_today_date()
    $.ajax
      url: '/api/graphs/daily_sparkline'
      data: 'zone_id=' + $("#current_domain").html() + '&queries_date=' + t.time
      dataType: 'JSON'
      type: 'GET'
      error: (json_data) ->
        $(".today").html("<div>" + json_data.responseText + "</div>")
      success: (json_data) ->
        $(".today").sparkline(json_data, {
          type: "line",spotColor: "#E7AF6E",
          minSpotColor: false,
          maxSpotColor: false,
          lineColor: "#70BFEE",
          fillColor: "#eee",
          spotRadius: "3",
          width: "262px",
          height: "92px"
        });

  render_graph2: ->
    t = get_today_month()
    $.ajax
      url: '/api/graphs/monthly_sparkline'
      data: 'zone_id=' + $("#current_domain").html() + '&month=' + t.time
      dataType: 'JSON'
      type: 'GET'
      error: (json_data) ->
        $(".this_month").html("<div>" + json_data.responseText + "</div>")
      success: (json_data) ->
        $(".this_month").sparkline(json_data, {
          type: "line",spotColor: "#E7AF6E",
          minSpotColor: false,
          maxSpotColor: false,
          lineColor: "#70BFEE",
          fillColor: "#eee",
          spotRadius: "3",
          width: "262px",
          height: "92px"
        });

  recheck: (e) ->
    e.preventDefault()
    # console.log @model
    myinfo = dashboard_info(@options.domain.get('combine'))
    myzone = @options.zone
    mydomain = @options.domain
    $.ajax
      url: '/api/zones/recheck'
      data: 'zone_id=' + @options.zone.get('id')
      success: (data) =>
      	# alert @model.get('combine')
      	if data
          z = new Dnscell.Models.Zone({id: domain2url( $("#current_domain").html() ) })
          z.fetch
            success: =>
              host = new Dnscell.Models.Host( $("#zone_data").data('host') )
              $("#zone_data").data('zone', z.toJSON())
              dashView = new Dnscell.Views.Dashboard(domain: host, zone: z, info: myinfo)
              $(".content_inside").html(dashView.render().el)
              $('.dashboard_tab').addClass('selected')
              $('.zone_notice').hide()
              show_notice("Your domain is now verified.")
      	else
      	  show_notice('We cant verify your current NS configuration.')
