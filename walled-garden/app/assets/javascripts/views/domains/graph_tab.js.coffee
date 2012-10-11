class Dnscell.Views.graph_tab extends Backbone.View

  template: JST['domains/graph_tab']

  events:
  	'click .time_selector>li':'time_selector'
  	'change .month_selector':'month_selector'

  time_selector: (e) ->
  	e.preventDefault()
  	index = $(".time_selector > li").index(e.currentTarget)
  	$(".time_selector > li a").removeClass("current")
  	$(".graph_item").hide()
  	$(".graph_item:eq(#{index})").show()
  	$(".time_selector > li:eq(#{index}) a").addClass("current")
  	switch index
  		when 0
        @render_graph()
  			#console.log '1'
  		when 1
        @render_graph2()
        @render_graph3()

  render: ->
    $(@el).html(@template(zone: @options.zone, host: @options.host))
    this

  render_graph: ->
    $.ajax
      url: '/api/graphs/daily'
      data: 'zone_id=' + $("#current_domain").html() + '&queries_date=' + $('#graph_date').val()
      dataType: 'JSON'
      type: 'GET'
      error: (json_data) ->
        $("#visualization").html("<div class='notice_normal'>" + json_data.responseText + "</div>")
      success: (json_data) ->
        data = google.visualization.arrayToDataTable(json_data);
         # Create and draw the visualization.
        ac = new google.visualization.ComboChart(document.getElementById('visualization'));
        ac.draw(data, {
          title : 'Daily queries at every Hour',
          width: '100%',
          height: 400,
          vAxis: {title: "Queries"},
          hAxis: {title: "Hours"},
          seriesType: "line",
          series: {1: {type: "line"}}
        });
        
  render_graph2: ->
    $.ajax
      url: '/api/graphs/monthly'
      data: 'zone_id=' + $("#current_domain").html() + '&month=' + $(".month_selector").val()
      dataType: 'JSON'
      type: 'GET'
      error: (json_data) ->
        $("#visualization_month").html("<br><div class='notice_normal'>" + json_data.responseText + "</div>")
      success: (json_data) ->
        data = google.visualization.arrayToDataTable(json_data);
         # Create and draw the visualization.
        ac = new google.visualization.ComboChart(document.getElementById('visualization_month'));
        ac.draw(data, {
          title : 'Monthly Queries by Date',
          width: '100%',
          height: 400,
          vAxis: {title: "Queries"},
          hAxis: {title: "Date"},
          seriesType: "line",
          series: {1: {type: "line"}}
        });
  
  render_graph3: ->
    $.ajax
      url: '/api/graphs/monthly'
      data: 'zone_id=' + $("#current_domain").html() + '&month=' + $(".month_selector").val() + '&threshold=true'
      dataType: 'JSON'
      type: 'GET'
      error: (json_data) ->
        $("#visualization_month2").html("<br><div class='notice_normal'>" + json_data.responseText + "</div>")
      success: (json_data) ->
        data = google.visualization.arrayToDataTable(json_data);
         # Create and draw the visualization.
        ac = new google.visualization.ComboChart(document.getElementById('visualization_month2'));
        ac.draw(data, {
          title : 'Monthly Queries by Date (threshold)',
          width: '100%',
          height: 400,
          vAxis: {title: "Queries"},
          hAxis: {title: "Date"},
          seriesType: "line",
          series: {1: {type: "line"}}
        });      

  month_selector: (e) ->
    @render_graph2()
    @render_graph3()