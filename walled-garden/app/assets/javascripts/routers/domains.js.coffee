class Dnscell.Routers.Domains extends Backbone.Router
  routes: {
    'apps_management/domains/': 'index'
    'apps_management/domains': 'index'
    'hosts/:id': 'hosts'
    'apps_management/domains/:id': 'show_zone'
    'u/:username': 'show_user'
  }

  collection: null

  initialize: (id) ->
    @collection = new Dnscell.Collections.Domains()

  index: =>

  hosts: (id) ->

  show_zone: (id) ->
    @model = new Dnscell.Models.Host(id: id)
    @model.fetch({
      success: =>
        z = new Dnscell.Models.Zone({id: domain2url(@model.get('combine')) })
        z.fetch
          success: =>
            ns_loss_check(z.get('zone_status'), z.get('zone_current_status'))
            $("#zone_id").val(z.get('id'))
            $("#zone_data").data('zone', z.toJSON())

            $("#domain_id").val( @model.get('id') )
            $("#zone_data").data('host', @model.toJSON())
            
            domainView = new Dnscell.Views.DomainShow(model: @model)
            domainView.render()
            $('.dash_tab').removeClass('selected')

            switch $("#tab_state").val()
              when "hosts_tab"
                $(".hosts_tab").click()
              when "dashboard_tab"
                $(".dashboard_tab").click()
              when "audit_tab"
                $(".audit_tab").click()
              when "ns_tab"
                if $(".ns_tab").length > 0
                  $(".ns_tab").click()
                else
                  $(".dashboard_tab").click()
              when "share_tab"
                if $(".share_tab").length > 0
                  $(".share_tab").click()
                else
                  $(".dashboard_tab").click()
              when "assign_tab"
                if $(".assign_tab").length > 0
                  $(".assign_tab").click()
                else
                  $(".dashboard_tab").click()
              when "dnssec_tab"
                if $(".dnssec_tab").length > 0
                  $(".dnssec_tab").click()
                else
                  $(".dashboard_tab").click()
              when "graph_tab"
                $(".graph_tab").click()
              else
                $(".dashboard_tab").click()
      error: ->
      })

    $("#current_domain").html(id.replace(/\_/g, '.'))

    @collection.fetch({
      success: => 
        @render_sidebar(id)
    })

    $("a[href='#{id}']").parent().addClass('current')

  render_sidebar: (id) =>
    $('#domains').html("")
    view = new Dnscell.Views.DomainsIndex(collection: @collection)
    view.render()
    $("a[href='#{id}']").parent().addClass('current')

  show_user: (username) ->
   alert "show_user #{username}"
