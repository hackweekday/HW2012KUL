class Dnscell.Views.SettingVanity extends Backbone.View
	template: JST['domains/setting_vanity']

	events:
		'click #close_vanity':'closeForm'
		'submit #vanity_form':'updateVanity'

	render: ->
		$(@el).html( @template(zone: @options.zone, vanity_host: @options.vanity_host) )
		this

	closeForm: (event) ->
		event.preventDefault()
		$("#modal").modal("hide")

	updateVanity: (event) ->
		event.preventDefault()
		zone_id = @options.zone.get('id')
		vanity = new Backbone.Model()
		vanity.url = '/api/zones/' + zone_id + '/create_update_vanity'
		attributes = 
    		host1: $("#host1").val()
    		host2: $('#host2').val()
    		id1: $('input#host1').data('id') 
    		id2: $('input#host2').data('id')  
		vanity.save attributes,
			wait: true
			success: =>
				$("#vanity_form")[0].reset()
				$("#modal").modal("hide")
				nservers = new Backbone.Collection()
				nservers.url = '/api/zones/' + zone_id + '/fetch_vanity_name_servers'
				nservers.fetch
					success: =>
						ns_list = new Dnscell.Views.NsList(zone: @options.zone, nameservers: nservers)
						$('.nameservers_list').html( ns_list.render().el )
			error: @handleErr
			show_notice("Your request for vanity nameserver is processed successfully")

	handleErr: (entry, response) =>
		if response.status == 422
			errors = $.parseJSON(response.responseText).errors
			formError = new Dnscell.Views.FormError(collection: errors)
			@$("#error_explanation").remove()
			@$(".item:visible > .modal-body").prepend("<div id='error_explanation'></div>")
			@$("#error_explanation").html(formError.render().el)
