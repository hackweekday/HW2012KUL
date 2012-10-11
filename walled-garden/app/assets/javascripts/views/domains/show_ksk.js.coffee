class Dnscell.Views.ShowKsk extends Backbone.View
	template: JST['domains/show_ksk']

	render: ->
  	$(@el).addClass('dnssec_content').html(@template(ksk_values: @options.ksk_values))
  	this