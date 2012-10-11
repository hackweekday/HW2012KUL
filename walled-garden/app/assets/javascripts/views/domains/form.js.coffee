class Dnscell.Views.DomainForm extends Backbone.View

  template: JST['domains/form']

  initialize: ->
  #  @model.on('add', @)

  events:
    'submit #zone_form': 'createDomain'
    'submit #zone_form_system': 'createDomain2'
    'click .close': 'closeForm'
    'click .create_domain_selector_form1': 'showForm1'
    'click .create_domain_selector_form2': 'showForm2'

  closeForm: (e) ->
    e.preventDefault()
    $("#modal").modal("hide")

  createDomain: (event) =>
    event.preventDefault()
    zone = new Dnscell.Models.Zone()
    attributes = 
      zone_name: $('#zone_zone_name').val()
      template_id: $('#zone_template_id').val()
      zone_default_ttl: $('#zone_zone_default_ttl').val()
      zone_service: $('#zone_zone_service').val()
      combine: $('#zone_zone_name').val()
    console.log "x"
    console.log attributes
    console.log "x"
    zone.save attributes,
      wait: true
      success: =>
        $("#zone_form")[0].reset()
        $("#modal").modal("hide")
        console.log zone.get('zone_name')
        host = new Dnscell.Models.Host(id: domain2url(zone.get('zone_name')))
        host.fetch({
          success: ->
            view = new Dnscell.Views.Domain(model: host)
            $('#domains').append(view.render().el)
            $('#current_domains_count').html(parseInt($('#current_domains_count').text()) + 1 )
            Dnscell.Views.DomainForm.prototype.domains_length_check()
            show_notice("Domain created.")
          error: @handleError
          })
      error: @handleError

  createDomain2: (event) =>
    event.preventDefault()
    attributes = 
      subdomain: $('#host_subdomain').val()
      domain: $('#host_domain').val()
      primary_host: true
      from_share: true
    host = new Dnscell.Models.Host()
    host.save attributes,
      wait: true
      success: =>
        $("#zone_form_system")[0].reset()
        $("#modal").modal("hide")
        # domain = new Dnscell.Models.Domain(id: domain2url(host.get('domain')))
        # domain.fetch({
        #   success: ->
        #     domainView = new Dnscell.Views.Domain(model: domain)
        #     $('#domains').append(domainView.render().el)
        #     # alert "get domain #{domain.get('zone_name')}"
        #   error: ->
        #     @handleError
        #   })
        view = new Dnscell.Views.Domain(model: host)
        $('#domains').append(view.render().el)
        $('#current_domains_count').html(parseInt($('#current_domains_count').text()) + 1 )
        Dnscell.Views.DomainForm.prototype.domains_length_check()
        show_notice("Domain created.")
      error: @handleError

  render: ->
    #alert @model.get('zone_name')
    #alert 'domain ' + domain.get('zone_name')
    #$(@el).html(@template(entry: @model))
    system_domains = shares.map (x) ->
      x.get "zone_name"
    console.log system_domains
    $("#modal").html($(@el).html(@template({domain: @model, system_domains: system_domains})))
    $("#modal").modal()
    # $("#modal_box").modal()
    # $("#modal").show()
    this

  handleError: (entry, response) =>
    if response.status == 422
      errors = $.parseJSON(response.responseText).errors
      formError = new Dnscell.Views.FormError(collection: errors)
      @$("#error_explanation").remove()
      @$(".item:visible > .modal-body").prepend("<div id='error_explanation'></div>")
      @$("#error_explanation").html(formError.render().el)
      #for attribute, messages of errors
      #  alert "#{attribute} #{message}" for message in messages

  domain_selected: (event) ->
    event.preventDefault()
    #alert @model.get('id')
    $("#domains > li.current").removeClass("current")
    $("#domain_#{@model.get('id')}").parent().addClass('current')
    Backbone.history.navigate("apps_management/domains/#{@model.get('combine')}".replace(/\./g, '_') , true)

  showForm1: (event) =>
    $(".item").hide()
    $("#zone_form").show()
    $(".create_domain_selector_form2").removeClass('selected')
    $('.create_domain_selector_form1').addClass('selected')

  showForm2: (event) =>
    $(".item").hide()
    $("#zone_form_system").show()
    $(".create_domain_selector_form1").removeClass('selected')
    $('.create_domain_selector_form2').addClass('selected')

  domains_length_check: (a) =>
    # alert 'ss'
    domains = new Dnscell.Collections.Zones()
    domains.url = '/api/zones'
    domains.fetch
      success: ->
        if domains.length == 1
          window.location = '/apps_management/domains'
