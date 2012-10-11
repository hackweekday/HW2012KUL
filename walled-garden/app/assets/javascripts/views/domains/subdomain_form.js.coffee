class Dnscell.Views.SubdomainForm extends Backbone.View
  template: JST['domains/subdomain_form']
  

  events:
  	"submit": "saveSubdomain"
  	"click .close": "closeModal"

  initialize: ->
  	# console.log @model
    # @model.on('add', @added, this)

  render: ->
    $(@el).html(@template(domain: $("#dttb_host").val()))
    this

  saveSubdomain: (e) ->
    e.preventDefault()
    subdomain = new Dnscell.Models.Host()
    attributes = 
      subdomain: $('#host_subdomain').val()
      domain: $('#host_domain').val()
      service: $("#host_service").val()
      domain_id: $('#host_domain').val()
    subdomain.save attributes,
      wait: true
      success: =>
        $("#modal").modal("hide")
        # view = new Dnscell.Views.Domain(model: subdomain)
        # hostView = new Dnscell.Views.HostEach({model: subdomain})
        # $('.host_list').append(hostView.render().el)
        $('#event_id').val(subdomain.get('id'))
        $('#event').val("create")
        $("#hosts_dttb").dataTable().fnDraw()
        $(".host_count").html( parseInt($(".host_count").text()) + 1 )
        show_notice("Subdomain created.")
        $("#event").val('subdomain_created')
      error: @handleError

  closeModal: (event) ->
  	event.preventDefault()
  	$("#modal").modal("hide")

  handleError: (entry, response) =>
    if response.status == 422
      errors = $.parseJSON(response.responseText).errors
      formError = new Dnscell.Views.FormError(collection: errors)
      @$("#error_explanation").remove()
      @$(".modal-body").prepend("<div id='error_explanation'></div>")
      @$("#error_explanation").html(formError.render().el)

  added: ->
  	alert 'added'