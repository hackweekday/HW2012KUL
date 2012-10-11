`services = ["Resource Record", "Domain Forwarding", "Dynamic DNS", "Short URL", "NS Delegation"]`

window.update_record_count = ->
  new_record_count = parseInt($(".record_count").text()) + 1
  $(".record_count").html( new_record_count )
  $("#record_count").val( new_record_count )
  $("#record_form").modal("hide")

window.get_host_count = (model) ->
  $.ajax({
    url: "/api/hosts/count?host_id=" + domain2url(model.get('reference1'))
    dataType: "json"
    success: (count) =>
      # alert count
      $(".host_count").html(count)
    })

window.get_quota_info = () ->
  @r = ""
  $.ajax({
    url: "/get_quota_info"
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.dnssec_plan = (zone_name) ->
  @r = ""
  $.ajax({
    url: "/dnssec_plan?zone_name=" + zone_name
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.graphs_plan = (zone_name) ->
  @r = ""
  $.ajax({
    url: "/graphs_plan?zone_name=" + zone_name
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.vanity_plan = (zone_name) ->
  @r = ""
  $.ajax({
    url: "/vanity_plan?zone_name=" + zone_name
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.audit_plan = (zone_name) ->
  @r = ""
  $.ajax({
    url: "/audit_plan?zone_name=" + zone_name
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.get_plan_info = () ->
  @r = ""
  $.ajax({
    url: "/get_plan_info"
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r


window.get_utc_time = () ->
  @r = ""
  $.ajax({
    url: "/api/graphs/get_utc_time"
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.get_time_now = () ->
  @r = ""
  $.ajax({
    url: "/api/graphs/get_time_now"
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.get_time_offset = () ->
  @r = ""
  $.ajax({
    url: "/api/graphs/get_time_offset"
    dataType: "json"
    async: false
    success: (result) =>
      @r = result.toString()
    })
  @r

window.get_today_date = () ->
  @r = ""
  $.ajax({
    url: "/api/graphs/get_today_date"
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.get_today_month = () ->
  @r = ""
  $.ajax({
    url: "/api/graphs/get_today_month"
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.stats_users = () ->
  @r = ""
  $.ajax({
    url: "/stats/stats_users"
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.dashboard_info = (domain) ->
  @r = ""
  $.ajax({
    url: "/api/zones/dashboard_info?zone_id="+domain
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.get_current_scope = (combine) ->
  @r = ""
  $.ajax({
    url: "/api/user_scope_assign/"+domain2url(combine)
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.get_record_count = (host_id) ->
  $.ajax({
    url: "/api/records/count?host_id=" + host_id
    dataType: "json"
    success: (count) =>
      # alert count
      $(".record_count").html(count)
      $("#record_count").val(count)
      # alert count
    })

window.get_dnssec_status = (zone_id) ->
  @r = ""
  $.ajax({
    url: "/api/zones/"+zone_id+"/get_dnssec_status"
    dataType: "json"
    async: false
    success: (result) =>
      @r = result.status
    })
  @r

window.get_scope = (id) ->
  @r = ""
  $.ajax({
    url: "/api/scopes/"+id
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

window.get_user_scope = (id) ->
  @r = ""
  $.ajax({
    url: "/api/scopes/"+id+"/show_user_scope"
    dataType: "json"
    async: false
    success: (result) =>
      @r = result
    })
  @r

#
window.get_dnssec_status = (zone_id) ->
  @r = ""
  $.ajax({
    url: "/api/zones/"+zone_id+"/get_dnssec_status"
    dataType: "json"
    async: false
    success: (result) =>
      @r = result.status
    })
  @r

window.get_api_token = () ->
	@r = ""
	$.ajax({
    url: "/api/users/get_api_token"
    dataType: "json"
    async: false
    success: (result) =>
    	@r = result
  	})
  @r

window.get_mxs_count = (host_id) ->
  $.ajax({
    url: "/api/records/mxs_count?host_id=" + host_id
    dataType: "json"
    success: (count) =>
      # alert count
      $(".mx_count").html(count)
      $("#mx_count").val(count)
      # alert count
    })

window.check_cname = (model) ->
  @kentang = ""
  $.ajax
    url: '/api/hosts/check_cname'
    data: "id=" + model.get('id')
    dataType: "json"
    async: false
    success: (data) => 
      @kentang = data
  if @kentang
    show_error "Already have CNAME in a record. Cannot add any other record anymore."

window.bind_ajaxStart = ->
	$("#modal_loading").ajaxStart ->
		$(this).show(); 
	.ajaxStop ->
		$(this).hide();

window.handleError = (entry, response) ->
	console.log entry
	console.log response
	if response.status == 422
	  errors = $.parseJSON(response.responseText).errors
	  formError = new Dnscell.Views.FormError(collection: errors)
	  @$("#error_explanation").remove()
	  console.log @$("form:visible:last > .modal-body")
	  if @$("form:visible:last > .modal-body").length > 0 
		  @$("form:visible:last > .modal-body").prepend("<div id='error_explanation'></div>")
	  else
	  	@$("form:visible:last").prepend("<div id='error_explanation'></div>")
	  # @$("form:visible:last > .modal-body").prepend("<div id='error_explanation'></div>")
	  @$("#error_explanation").html(formError.render().el)

window.show_error = (msg) ->
  $( "#modal_error" ).modal()
  $( '.error_text' ).html(msg)

window.add_rr_row = (model) ->
	rView = new Dnscell.Views.RecordOneRow({model: model})
	$(".rr_loop").append(rView.render().el)
	show_notice "Record added."
	update_zebra_table()
	$("#rr_#{model.get('id')} td").effect("highlight", {}, 8000)
	$(".no_record_tr").hide()

window.update_rr_row = (model) ->
	if model.get('record_type') == 'MX'
		$("#rr_" + model.get('id')).find("td:eq(1)").html( model.get('priority') )
		$("#rr_" + model.get('id')).find("td:eq(2)").html( model.get('mx_host') )
		$("#rr_" + model.get('id')).find("td:eq(3)").html( model.get('ttl') )
	else
		$("#rr_" + model.get('id')).find("td:eq(2)").html( model.get('content') )
		$("#rr_" + model.get('id')).find("td:eq(3)").html( model.get('ttl') )
	$("#rr_data_#{model.get('id')}").data('record', model.toJSON() )
	show_notice "Record updated."
	$("#record_form").modal('hide')
	$("#rr_#{model.get('id')} td").effect("highlight", {}, 8000)
	$(".no_record_tr").hide()

window.domain2url = (string) ->
	string.replace /\./g, "_"

window.url2domain = (string) ->
	string.replace /\_/g, "."

window.show_notice = (message) ->
	$(".notice_wrap").fadeIn()
	$(".notice").html message
	$(".notice_wrap").delay(8000).fadeOut()

#remove border datatable
window.dttb_border = (id = '') ->
	$(id + '.dataTables_wrapper').find(".ui-widget-header").first().addClass "no_border_bottom"
	$(id + '.dataTables_wrapper').find(".ui-widget-header").last().addClass "no_border_top"
	$('.edit_icon').attr('title','Edit').tipsy({gravity: 's'});
	$('.delete_icon').attr('title','Delete').tipsy({gravity: 's'});

window.show_manage_host = ->
	$( "#manage_host" ).modal().css
		"margin-left": '-45%'
		"width": '90%'
		"z-index": 700
	$(".modal-backdrop").css
		"z-index": 699		
  # checkWidth("#manage_host")

window.update_zebra_table = ->
  $('.zebra_table tr').removeClass('odd')
  $('.zebra_table tr:even').addClass('odd')
	# $("#manage_host").html(html)
	# $("#manage_host").modal().css
 #      "margin-left": '-45%'
 #      "width": '90%'

window.initiate_tooltip = ->
	$('.tipsy_bottom').tipsy({gravity: 'n'});
	$('.tipsy_top').tipsy({gravity: 's'});
	$('.tipsy_left').tipsy({gravity: 'e'});
	$('.tipsy_right').tipsy({gravity: 'w'});

$ -> 
	# $(".add_domain").sparkline [ 10, 8, 5, 7, 4, 4, 1 ],
	# 	type: "line"
	# 	spotColor: "#E7AF6E"
	# 	minSpotColor: false
	# 	maxSpotColor: false
	# 	lineColor: "#70BFEE"
	# 	fillColor: "#eee"
	# 	spotRadius: "3"
	# 	width: "262px"
	# 	height: "92px"

	# $('.why_sidebar').stickyScroll({ topBoundary: 200, container: $('.w_sidebar') })
	# $('.w_sidebar').containedStickyScroll()
	$(".why_sidebar").fixed top: "60"

	initiate_tooltip()

	#remove border datatable
	dttb_border = ->
		$('.dataTables_wrapper').find(".ui-widget-header").first().addClass "no_border_bottom"
		$('.dataTables_wrapper').find(".ui-widget-header").last().addClass "no_border_top"

	#guide untuk notice
	$('.show_notice').click ->
		show_notice 'Test'

	#register country
	$("#user_country").change()

	$(".domain_label_block").hide()

	#sidebar toggle
	$(".label_trigger").click (event) ->
		event.stopPropagation() 
		event.preventDefault()

		$(".domain_label_block").toggle()

	# datatatble
	$('#demo_dttb').dataTable
	    bJQueryUI: true
	    fnFooterCallback: ->
	    	dttb_border()

	#make sidebar & content same height
	side = $('.domain_sidebar').height()
	main = $('.content_with_sidebar').height()
	
	if main > side
		#$('.content_with_sidebar').height(side)
	else 
		#$('.domain_sidebar').height(main)

	#chosen
	#$(".chozen, .select_scope").chosen()
	$(".chozen").chosen()
	
	#check visible portion
	wwidth = ->
		(if (window.innerWidth) then window.innerWidth else document.documentElement.clientWidth or document.body.clientWidth or 0)
	wheight = ->
	  	(if (window.innerHeight) then window.innerHeight else document.documentElement.clientHeight or document.body.clientHeight or 0)
	
	calc_browser = ->
		$('.browser_portion').html "height: " + wheight() + ", width: " + wwidth() + ', container: ' + $('.container').width() + ', grid_9: ' + $('.grid_9').width() + ', grid_3: ' + $('.grid_3').width()
		#console.log $('.grid_3').width()
		$('.domain_list').css
			"height": wheight() - 310

	$(window).resize ->
		calc_browser()
		#checkWidth()

	calc_browser()
			
	#modalbox
	$('.show_modal').click ->
		$( "#guide_box" ).modal().css
			"margin-left": -280
			"width": 560

	$('.show_error').click ->
		$( "#modal_error" ).modal()
		$('.error_text').html('Test')

	$('.show_loading').click ->
		$( "#modal_loading" ).fadeIn()

	$('.show_modal_big').click ->
		$( "#guide_box2" ).modal().css
			"margin-left": '-45%'
			"width": '90%'
			"z-index": 700
		$(".modal-backdrop").css
			"z-index": 699		
		checkWidth("#guide_box2")
		
	checkWidth = (modal_class) ->
		if $(modal_class).width() > 1180
			$(modal_class).css
				"margin-left": '-590px'
				"width": '1180px'
		else
			$(modal_class).modal().css
				"margin-left": '-45%'
				"width": '90%'

 	#  		"margin-top": ->
 	#    		-($(this).height() / 2)
	bind_ajaxStart()

	$(".nano").nanoScroller()

	# $(".copy_url").live( 'click', (target) -> 
	# 	alert $(this).prev().attr('href')
	# 	$(this).zclip({
	# 		path:'/ZeroClipboard.swf'
	# 		copy: ->
	# 			$(this).prev().attr('href')
	# 		afterCopy: ->
	# 			alert 'copied'
	# 	})
	# )

	$(".copy_ksk").live( 'click', (target) -> 
		#alert $(this).next().html()
		$(this).zclip({
			path:'/ZeroClipboard.swf'
			copy: ->
				$(this).next().html()
		})
	)

	#static login
	$('.start_now').click (e) ->
		e.preventDefault()
		$('.sign_in_wrap').toggle()

	$("#slider_home").responsiveSlides
		maxwidth: 1200
		speed: 800

	$("#slider_video").responsiveSlides
		auto: false
		#nav: true
		pager: true
		maxwidth: 1200
		speed: 800

	$(".rslides_tabs li").each (index, element) ->
		index++
		$('.rslides_tabs li:nth-child('+index+') a').addClass('v'+index+' tipsy_top')

	$('.rslides_tabs li:nth-child(1) a').attr('title', 'DNSSocial : Create Domain and host')
	$('.rslides_tabs li:nth-child(2) a').attr('title', 'DNSSocial : Custom Nameserver')
	$('.rslides_tabs li:nth-child(3) a').attr('title', 'DNSSocial : Assign domain with friend')
	$('.rslides_tabs li:nth-child(4) a').attr('title', 'DNSSocial : Share host with your friend')
	$('.rslides_tabs li:nth-child(5) a').attr('title', 'DNSSocial : Signing your domain with DNSSEC')
	$('.rslides_tabs li a').tipsy({gravity: 's'});

window.ns_loss_check = (x, y) ->
	# if x == true && y == false
	if y
		$(".zone_notice").hide()
	else
		$(".zone_notice").show()

window.append_domain_to_sidebar = (d, d_id) ->
	Domain = Backbone.Model.extend()
	domain = new Domain(
  	combine: d
  	id: d_id
	)
	console.log d
	console.log d_id
	Dnscell.Views.DomainsIndex.prototype.appendZone( domain )
	#$('#domains li#domain_'+d_id).effect("highlight", {}, 8000)

window.vanity_status = (zone_id) ->
	@r = ""
	$.ajax({
		url: '/api/zones/' + zone_id + '/fetch_ns_hosts'
		dataType: "json"
		async: false
		success: (result) =>
	  		@r = result
	})
	if (@r)
		@r.vanity_status
	else
		false
	
