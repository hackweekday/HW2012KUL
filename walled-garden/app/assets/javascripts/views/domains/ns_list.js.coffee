class Dnscell.Views.NsList extends Backbone.View
	template: JST['domains/ns_list']

	render: ->
  	$(@el).html(@template ( zone: @options.zone, nameservers: @options.nameservers))
  	this