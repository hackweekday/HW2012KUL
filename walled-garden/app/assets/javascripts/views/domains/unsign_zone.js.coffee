class Dnscell.Views.UnsignZone extends Backbone.View
  template: JST['domains/unsign_zone']

  events:
    'click #sign_zone': 'signZone'

  render: ->
    $(@el).html( @template(zone: @options.zone, host: @options.host) )
    this

  signZone: (event) ->
  	$.ajax
      url: '/api/zones/sign_zone'
      data: 'zone_id=' + @options.zone.get('id')
      success: (data) ->
          if data
            z = new Dnscell.Models.Zone({id: domain2url( $("#current_domain").html() ) })
            z.fetch
              success: =>
                h = new Dnscell.Models.Host( $("#zone_data").data('host') )
                dnssecView = new Dnscell.Views.SignedZone(zone: z, host: h)
                $(".content_dnssec").html(dnssecView.render().el)
                $('.ds_tab').addClass('current')
                show_notice("Successfully signed")
              error: =>
                show_error("error unsigned")
          else
            show_error("error unsigned")
    event.preventDefault()