class Dnscell.Views.PlanForm extends Backbone.View
	template: JST['user_settings/plan_form']


	events:
		"submit form":"submit"
		"click .close":"close_form"

	render: ->
		$(@el).html(@template(user: @user, plan: @plan))
		this

	close_form: (e) ->
		$(".plan_form").modal("hide")

	submit: (e) ->
		e.preventDefault()
		u = @user
		@model = new Backbone.Model
		@model.url = '/change_plan'
		attributes = 
			promo_code: $("#promo_code").val()
		@model.save attributes,
			wait: true
			success: =>
				show_notice("Plan changed")
				$(".plan_form").modal("hide")
				settingContainer = new Dnscell.Views.user_change_plan(model: u)
				$(".content_inside").html(settingContainer.render().el)
			error: (entry, response) =>
				handleError(entry, response)

	handleError: (entry, response) =>
		if response.status == 422
			errors = $.parseJSON(response.responseText).errors
			formError = new Dnscell.Views.FormError(collection: errors)
			@$("#error_explanation").remove()
			@$(".item:visible > .modal-body").prepend("<div id='error_explanation'></div>")
			@$("#error_explanation").html(formError.render().el)