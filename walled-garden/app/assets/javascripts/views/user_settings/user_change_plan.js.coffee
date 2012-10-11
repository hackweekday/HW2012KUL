class Dnscell.Views.user_change_plan extends Backbone.View

  template: JST['user_settings/user_change_plan']

  events:
    'click #change_plan_button': 'changePlan'

  render: =>
    p = get_plan_info()
    $(@el).html(@template(user: @model, plan: p))
    this

  changePlan: (event) ->
    event.preventDefault()
    p = get_plan_info()
    planForm = new Dnscell.Views.PlanForm(user: @model, plan: p)
    $(".plan_form").html(planForm.render().el).modal()