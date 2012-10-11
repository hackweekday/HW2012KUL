class Dnscell.Views.assign_tab extends Backbone.View
  template: JST['domains/assign_tab']

  events:
    'click #create_assign': 'createAssign'
    'click .delete_assign': 'deleteAssign'

  render: ->
    $(@el).html(@template(zone: @options.zone, scopes: @options.scopes ))
    this

  deleteAssign: (event) ->
    event.preventDefault()
    if confirm("Are you sure?")
      @model = new Dnscell.Models.UserScopeAssign(id: domain2url(@options.zone.get('zone_name')) + "_" + event.currentTarget.id )
      myzone = @options.zone
      @model.destroy
        success: ->
          scopes = new Dnscell.Collections.UserScopeAssigns()
          scopes.fetch
            data: { id: domain2url($("#zone_data").data('zone').zone_name) }
            success: =>
              #assign_tab_view = new Dnscell.Views.assign_tab(zone: myzone, scopes: scopes)
              #$("#scope_view").html( assign_tab_view.render().el )
              $('tr#'+event.currentTarget.id).remove()
              if $('.assign_table tr').size()-1 == 0
                $('.assign_table').hide()
                $('.assign_pic').show()

          show_notice("Assign access is successfully revoked")
    event.preventDefault()
  
  createAssign: (event) ->
    createAssignView = new Dnscell.Views.CreateAssign(zone: @options.zone)
    $("#modal").html(createAssignView.render().el).modal()