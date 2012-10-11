class Dnscell.Views.SignedZone extends Backbone.View
	template: JST['domains/signed_zone']

	events:
    'click #unsign_zone': 'unsignZone'
    'click .ds_tab': 'dsTab'
    'click .dnskey_tab': 'dnskeyTab'
    'click .ds_zsk': 'dsZsk'

	render: ->
    $(@el).html(@template(zone: @options.zone, host: @options.host))
    $('.dnssec_content').html( @fDs("KSK") )  
    this

  unsignZone: (event) ->
    if confirm "Are you sure to unsign this domain?"
    	$.ajax
	      url: '/api/zones/unsign_zone'
	      data: 'zone_id=' + @options.zone.get('id')
	      success: (data) ->
	        if data
	          z = new Dnscell.Models.Zone({id: domain2url( $("#current_domain").html() ) })
	          z.fetch
	            success: =>
	              h = new Dnscell.Models.Host( $("#zone_data").data('host') )
	              dnssecView = new Dnscell.Views.UnsignZone(zone: z, host: h)
	              $(".content_dnssec").html(dnssecView.render().el)
	              show_notice("Successfully unsigned")
	            error: =>
	              show_error("error unsigned")
	        else
	          show_error("error unsigned")
      event.preventDefault()

 
  dsTab: (event) ->
    event.preventDefault()
    $('.dnskey_tab').removeClass('current')
    @fDs("KSK")

  dnskeyTab: (event) ->
    event.preventDefault()
    $('.ds_tab').removeClass('current')
    @fDnskey()

  dsZsk: (event) ->
    event.preventDefault()
    ds = new Backbone.Collection()
    ds.url = '/api/zones/fetch_ds?zone_id=' + @options.zone.get('id') + '&key_type=ZSK'
    ds.fetch
      success: (data) =>
        showZsk = new Dnscell.Views.ShowZsk(zsk_values: ds)
        $("#zsk").html(showZsk.render().el)

  fDs: (key_type) ->
    ds = new Backbone.Collection()
    ds.url = '/api/zones/fetch_ds?zone_id=' + @options.zone.get('id') + '&key_type=' + key_type
    ds.fetch
      success: (data) =>
        $('.ds_tab').addClass('current')
        showDs = new Dnscell.Views.ShowKsk(ksk_values: ds)
        $(".dnssec_content").html(showDs.render().el)

  fDnskey: ->
    $('.dnskey_tab').addClass('current')
    dnskey = new Backbone.Collection()
    dnskey.url = '/api/zones/fetch_dnskey?zone_id=' + @options.zone.get('id')
    dnskey.fetch
      success: (data) =>
        showDnskey = new Dnscell.Views.ShowDnskey(dnskey_values: dnskey)
        $(".dnssec_content").html(showDnskey.render().el)
      error:
        @err 

  err: ->
    $(".dnssec_content").html("Error fetching data, please try again or contact support@dnscell.com")
    show_error("Error fetching data, please try again or contact support@dnscell.com")
    $( "#modal_loading" ).fadeOut()
        