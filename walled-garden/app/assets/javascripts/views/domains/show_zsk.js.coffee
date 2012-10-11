class Dnscell.Views.ShowZsk extends Backbone.View
	template: JST['domains/show_zsk']

	render: ->
  	$(@el).html(@template(zsk_values: @options.zsk_values))
  	this