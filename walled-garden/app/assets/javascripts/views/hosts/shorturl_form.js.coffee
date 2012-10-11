class Dnscell.Views.shorturl_form extends Backbone.View

	template: JST['hosts/shorturl_form']

	render: ->
		$(@el).html(@template(host: @model, shorturl: @options.shorturl))
		this

	events:
		"submit":"submit"
		"click .close":"close"

	submit: (e) =>
		e.preventDefault()
		if $("#destination").val().match(/(http:\/\/|https:\/\/)/) == null
			destination = $("#destination").val()
			$("#destination").val( 'http://' + destination )
		attributes =
			host_id: $("#current_host_id").val()
			shortcode: $("#shortcode").val()
			destination: $("#destination").val()
		@options.shorturl.save attributes,
			wait: true
			success: ->
				$("#record_form").modal('hide')
				$("#shorturls").dataTable().fnDraw()
				show_notice("Short URL saved.")
			error: (a,b) =>
				handleError(a,b)

	close: (e) =>
		e.preventDefault()
		$("#record_form").modal('hide')