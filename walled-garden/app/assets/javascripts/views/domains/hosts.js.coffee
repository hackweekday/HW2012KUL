class Dnscell.Views.Hosts extends Backbone.View
  template: JST['domains/hosts']
  template2: JST['domains/single_host']

  initialize: ->
    # @collection.on('reset', @render, this)
    # @collection.on('add', @appendEntry, this)

  events:
    "click .new_host": "addHost"
    "click .delete_host": "deleteHost"
    "click .delete_all_host": "checkboxToggle"
    "click .new_snippet": "new_snippet"
    "click .delete_icon": "delete_one_host"

  new_snippet: (e) =>
    e.preventDefault()
    snippets = new Backbone.Collection()
    snippets.url = '/api/snippets/index'
    snippets.fetch
      success: (data) =>
        snippet_select = new Dnscell.Views.snippet_select(collection: snippets)
        $("#modal").html(snippet_select.render().el).modal()
        $('.snippet_selector').change()


  checkboxToggle: ->
    if $(".delete_all_host").is(":checked")
     $("input[type=checkbox][name^=host]:not(:disabled)").prop("checked", true)
    else
     $("input[type=checkbox][name^=host]").prop("checked", false)

  render: ->
    # console.log @collection.map (x) ->
    #   x.get "combine"
    $(@el).html(@template(many_host: @collection))
    # $('.host_list').html("")
    # @collection.each(@appendHost)
    this
    
  appendHost: (host) =>
    view = new Dnscell.Views.HostEach(model: host)
    $('.host_list').append(view.render().el)

  addHost: (event) ->
    event.preventDefault()
    domain = (if ( $('.chzn-container-single span').length ) then domain2url( $('.chzn-container-single span').text() ) else domain2url( $("#current_domain").text() ) )
    
    $.ajax({
      url: '/api/able_to_add_host?domain=' + domain,
      dataType: "json",
      type: "get",
      success: (data) ->
        if data == true
          subdomainForm = new Dnscell.Views.SubdomainForm(model: @model)
          $("#modal").html(subdomainForm.render().el)
          $("#modal").modal()
          # $("#modal").show()
        else
          # alert "Host limit reached! Please upgrade to Premium Account to add more host!"
          show_error("Quota has been exceeded, please upgrade.")
    })

  single: ->
    $(@el).html(@template(host: @model))
    this

  deleteHost: (event) =>
    if $(".host_list input:checked").serialize().length > 0
      if confirm "Are you sure?"
        Dnscell.Views.Hosts.prototype.delete_process()
    event.preventDefault()

  delete_one_host: (e) ->
    e.preventDefault()
    if confirm("Are you sure?")
      $(e.currentTarget).closest("tr").find("input").attr("checked", true)
      Dnscell.Views.Hosts.prototype.delete_process()

  delete_process: ->
    $.ajax
      url: "/api/hosts/delete_host"
      data: $(".host_list input:checked").serialize()
      success: ->
        $("#hosts_dttb").dataTable().fnDraw()
        $(".delete_all_host").prop("checked", false)
        $(".host_count").text( Number( $(".host_count").text() ) - Number( $(".host_list input:checked").length ) )
        show_notice("Subdomain deleted.")