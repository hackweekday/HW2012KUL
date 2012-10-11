class Dnscell.Views.dynamic_dns extends Backbone.View

  template: JST['hosts/dynamic_dns']

  render: ->
    $(@el).html(@template(dynamic_dns: @model))
    this

  events:
    "submit":"save"
    "click .use_my_ip":"use_my_ip"

  save: (e) =>
    e.preventDefault()
    dynamic_dns = new Backbone.Model()
    dynamic_dns.url = '/api/hosts/save_dynamic_dns'
    attributes =
      host_id: $("#current_host_id").val()
      dyn_ttl: $("#dyn_ttl").val()
      dyn_current_ip: $("#dyn_current_ip").val()
    dynamic_dns.save attributes,
      success: =>
        $("#error_explanation").remove()
        show_notice("Dynamic DNS saved.")
      error: (entry, response) =>
        handleError(entry, response)

  use_my_ip: (e) ->
    e.preventDefault()
    $("#dyn_current_ip").val($("#client_ip").val())