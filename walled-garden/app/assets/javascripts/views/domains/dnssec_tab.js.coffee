class Dnscell.Views.dnssec_tab extends Backbone.View
  # $(this.el).attr('id', 'id1').addClass('nice')
  template: JST['domains/dnssec_tab']

  #initialize: ->
  #initialize: ->
    #this.model.bind('change', this.render)

    #@options.zone.on('reset', @render, this)
    #  success: (data) ->
    #    console.log @zone_dnssec.get('zone_dnssec')
    
    #@zone_dnssec.on('change', @render, this)
    #@zone_dnssec.deferred = @zone_dnssec.fetch()
    #@zone_dnssec.fetch()
    #@options.dnssec.on('reset', @render, this)

    
  render: ->
    $(@el).addClass('content_dnssec').html(@template(zone: @options.zone, host: @options.host))

    result = get_dnssec_status(@options.zone.get('id'))
    if result is "true"
      dnssecView = new Dnscell.Views.SignedZone(zone: @options.zone, host: @options.host)
    else
      dnssecView = new Dnscell.Views.UnsignZone(zone: @options.zone, host: @options.host)
    
    $(".content_dnssec").html( $(@el).html( dnssecView.render().el ) )       
    this