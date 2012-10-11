class Dnscell.Views.user_payment_history extends Backbone.View

  template: JST['user_settings/user_payment_history']

  render: =>
    $(@el).html(@template(user: @model))
    this