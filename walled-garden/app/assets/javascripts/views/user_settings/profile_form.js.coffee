class Dnscell.Views.profile_form extends Backbone.View

  template: JST['user_settings/profile_form']

  render: ->
    $(@el).html(@template(user: @model, countries: @options.countries, timezones: @options.timezones))
    this

  initialize: ->

  events:
    "submit form":"submit"
    "change #user_country":"update_time_zone"
    "click .close":"close_form"

  close_form: (e) ->
    $(".profile_form").modal("hide")

  submit: (e) ->
    e.preventDefault()
    @model.url = '/api/users/haha'
    attributes = 
      name: $("#user_name").val()
      country: $("#user_country").val()
      timezone: $("#user_timezone").val()
      url: $("#user_url").val()
    @model.save attributes,
      wait: true
      success: =>
        show_notice("Profile Saved.")
        $(".profile_form").modal("hide")
        upView = new Dnscell.Views.user_profile(model: @model)
        $(".content_inside").html(upView.render().el)
        $(".content_header > h3:first").html(@model.get('name'))
      error: (entry, response) =>
        handleError(entry, response)

  update_time_zone: (e) ->
    tz = @model.get('timezone')
    $("#user_timezone").html("")
    timezones = @options.timezones.filter((tz) -> tz.get('country_code') == $("#user_country").val()).map((x) -> [ x.get('zone_name'), "(GMT" + x.get('time_zone') + ") " + x.get('zone_name')] )
    console.log timezones
    $.each(timezones, (i,v) ->
      selected = 'selected=selected' if v[0] == tz
      $("#user_timezone").append("<option value='#{v[0]}' #{selected}>#{v[1]}</option>") 
     )