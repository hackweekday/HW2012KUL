class Dnscell.Views.ns_tab extends Backbone.View
  template: JST['domains/ns_tab']

  events:
    'click #setting_vanity': 'vanity_form'
    'click #rollback_vanity': 'rollback'

  initialize: ->
    @options.nameservers.on('reset', @render, this)

  render: ->
    $(@el).html(@template( zone: @options.zone, nameservers: @options.nameservers ))
    ns_list = new Dnscell.Views.NsList(zone: @options.zone, nameservers: @options.nameservers)
    $('.nameservers_list').html( ns_list.render().el )
    this

  rollback: (event) ->
    event.preventDefault()
    zone = @options.zone
    zone_id = @options.zone.get('id')
    if confirm "Are you sure to rollback?"
      $.ajax
        url: '/api/zones/vanity_rollback'
        data: 'id=' + @options.zone.get('id')
        success: (data) ->
          if data
            nservers = new Backbone.Collection()
            nservers.url = '/api/zones/' + zone_id + '/fetch_vanity_name_servers'
            nservers.fetch
              wait: true
              success: =>
                ns_list = new Dnscell.Views.NsList(zone: zone, nameservers: nservers)
                $('.nameservers_list').html( ns_list.render().el )
        show_notice("Your request for rollback is processed successfully")



  vanity_form: (event) ->
    event.preventDefault()
    zone = @options.zone
    fetch_vanity_host = new Backbone.Model()
    fetch_vanity_host.url = '/api/zones/' + @options.zone.get('id') + '/fetch_ns_hosts'
    fetch_vanity_host.fetch
      success: ->
        settingVanityForm = new Dnscell.Views.SettingVanity(zone: zone, vanity_host: fetch_vanity_host)
        $("#modal").html(settingVanityForm.render().el).modal()