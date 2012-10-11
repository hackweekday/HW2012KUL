class Dnscell.Views.ShowDnskey extends Backbone.View
	template: JST['domains/show_dnskey']

	render: ->
  	$(@el).addClass('dnssec_content').html(@template(dnskey_values: @options.dnskey_values))
  	this