class Dnscell.Views.user_profile extends Backbone.View

  template: JST['user_settings/user_profile']

  render: ->
    $(@el).html(@template(user: @model))
    this

  events:
    "click .edit": "edit_profile"
    "click .chg_password": "chg_password"

  initialize: ->

  chg_password: ->
    $.ajax({
      url: "/api/users/password_length"
      dataType: "json"
      success: (data) ->
        console.log data
        passwordForm = new Dnscell.Views.change_password(model: @model, password_length: data)
        $("#modal").html(passwordForm.render().el).modal()
      })

  edit_profile: (e) ->
    e.preventDefault()

    timezones = new Backbone.Collection()
    timezones.url = "/api/users/timezones"
    uuser = @model
    timezones.fetch({
      success: ->
        countries = new Backbone.Collection()
        countries.url = "/api/users/countries"
        # ttemplate = @template
        countries.fetch({
          success: ->
            # $(@el).html(ttemplate(user: uuser, countries: countries, timezones: timezones))
            profileForm = new Dnscell.Views.profile_form({model: uuser, countries: countries, timezones: timezones})
            $(".profile_form")
              .html(profileForm.render().el)
              .modal()
            $("#user_country").change()
          })
      })