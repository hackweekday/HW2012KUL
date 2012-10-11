class Dnscell.Views.share_tab extends Backbone.View

	template: JST['domains/share_tab']

	events:
		'click #create_scope': 'createScope'
		'change .select_scope': 'select_scope'
		'click #revoke_share': 'revoke_share'

	render: ->
		$(@el).html(@template(zone: @options.zone, host: @options.host, scopes: @options.scopes ))
		this

	createScope: (event) ->
		createScopeView = new Dnscell.Views.CreateScope(zone: @options.zone, host: @options.host)
		$("#modal").html(createScopeView.render().el).modal()

	select_scope: (e) ->
		# alert $(".select_scope").val()
		@render_share_tab_content()

	revoke_share: (event) ->
		event.preventDefault()
		#alert $('.chzn-single span').text()
		#alert @options.zone.get('zone_name')
		zone = @options.zone 
		host = @options.host
		if confirm("Are you sure?")
			@model = new Dnscell.Models.Domain(id: domain2url( $('.chzn-single span').text() ))
			#@model = new Dnscell.Models.UserScopeAssign(id: domain2url(@options.zone.get('zone_name')) + "_" + event.currentTarget.id )
			@model.destroy
			#zones = @options.zone 
			#hosts = @options.host
				success: ->
					#alert zone.get('zone_name')
					scopes = new Dnscell.Collections.Scopes()
					scopes.fetch
	    			data: { zone_id: $("#zone_data").data('zone').id }
    				success: ->
    					#alert @options.zone.get('zone_name')
    					share_tab_view = new Dnscell.Views.share_tab(zone: zone, host: host, scopes: scopes)
    					$(".content_inside").html( share_tab_view.render().el )
    					Dnscell.Views.share_tab.prototype.render_share_tab_content()
					#$(".select_scope option[value='" + $('.chzn-single span').text() + "']").remove()
					#$(".chzn-results li.result-selected").remove
					#Dnscell.Views.share_tab.prototype.render_share_tab_content()	
				show_notice("Share access is successfully revoked")


	render_share_tab_content: (e) ->
		if $(".select_scope").children().length > 0
			#$(".select_scope, .scope_info").show()
			$(".share_pic").hide()
			scope = new Dnscell.Models.Scope id: $(".select_scope").children(':selected').attr('scope-id')
			scope.fetch
				success: ->
					#alert $(".select_scope").children().length
					#$(".chozen, .select_scope").chosen()
					#$(".select_scope").hide()
					@$('.share_to').html(scope.get('email'))
					@$('.status').html( if scope.get('status') then "Accepted" else "Pending" )
					@$('.created_at').html(scope.get('created_at'))
					$("#dttb_host").val($(".select_scope").val())
					$(".select_scope").chosen();
					$(".select_scope_full").show()
					if scope.get('status')
						hostsView = new Dnscell.Views.Hosts
						$(".share_tab_content").html(hostsView.render().el)
						$(".share_tab_content").show()
						render_hosts_dttb($(".select_scope").val())
					else
						$(".share_tab_content").hide()
		else
			$(".select_scope, .scope_info, .select_scope_full").hide()
			$(".share_pic").show()
			# $(".share_tab_content").hide()