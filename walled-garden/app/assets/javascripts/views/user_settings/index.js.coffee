class Dnscell.Views.UserSettingsIndex extends Backbone.View

  template: JST['user_settings/index']

  render: ->
  	$(@el).html(@template(user: @model))
  	this

  events: 
    "click .normal_tab>li>a": "tabSelect"

  tabSelect: (e) ->
    @$(".normal_tab > li > a").removeClass("selected")
    $(e.currentTarget).addClass("selected")
    e.preventDefault()
    switch $(e.currentTarget).attr("href")
      when "profile"
        settingContainer = new Dnscell.Views.user_profile(model: @model)
        Backbone.history.navigate("user/profile" , true)
      when "password"
        settingContainer = new Dnscell.Views.user_password(model: @model)
      when "api_token"
        settingContainer = new Dnscell.Views.user_api_token(model: @model)
        Backbone.history.navigate("user/api_token" , true)
      when "plan"
        settingContainer = new Dnscell.Views.user_change_plan(model: @model)
        Backbone.history.navigate("user/plan" , true)
      when "payment_history"
        settingContainer = new Dnscell.Views.user_payment_history(model: @model)
        Backbone.history.navigate("user/payment_history" , true)
    $(".content_inside").html(settingContainer.render().el)