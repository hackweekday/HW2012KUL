class Dnscell.Views.domain_forwarding extends Backbone.View

  template: JST['domains/domain_forwarding']

  render: ->
    $(@el).html(@template(forward: @model))
    this

  events:
    "submit":"save"
    "click #stealth":"show_additional_fields"

  show_additional_fields: (e) ->
    #e.preventDefault()
    if $("#stealth").is(':checked')
      $('#additional_fields').show()
    else
      $('#additional_fields').hide()

  save: (e) =>
    e.preventDefault()
    if $("#redirect_url").val().match(/(http:\/\/|https:\/\/)/) == null
      redirect_url = $("#redirect_url").val()
      $("#redirect_url").val( 'http://' + redirect_url )
    forward = new Backbone.Model()
    forward.url = '/api/hosts/save_forward'
    attributes =
      host_id: $("#current_host_id").val()
      destination: $("#redirect_url").val()
      title: $("#title").val()
      meta_keywords: $("#meta_keywords").val()
      meta_discription: $("#meta_discription").val()
      stealth: $("#stealth").is(':checked')
    forward.save attributes,
      success: =>
        $("#error_explanation").remove()
        show_notice("Forwarding saved.")
      error: (entry, response) =>
        handleError(entry, response)