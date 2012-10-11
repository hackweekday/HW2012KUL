class Dnscell.Views.CreateScope extends Backbone.View
  template: JST['domains/create_scope']

  events:
    'submit #scope_form': 'createScope'
    'click #close_create_scope': 'closeForm'

  render: ->
  #$("#modal").html( $(@el).html( @template( zone: @options.zone, host: @options.host ) ) ).modal()
    $(@el).html( @template(zone: @options.zone, host: @options.host) )
    this

  closeForm: (event) ->
    event.preventDefault()
    $("#modal").modal("hide")

  createScope: (event) =>
    event.preventDefault()
    scope = new Dnscell.Models.Scope()
    attributes = 
      subdomain: $('#scope_subdomain').val()
      domain: $("#current_domain").html()
      email: $('#scope_email').val()
    scope.save attributes,
      wait: true
      success: =>
        $("#scope_form")[0].reset()
        $("#modal").modal("hide")        
        #$(".chzn-select").chosen() 
        		# h = new Dnscell.Models.Host( $("#zone_data").data('host') )
        		# view = new Dnscell.Views.share_tab(zone: z, host: h)
        		# $('#scope_view').html(view.render().el)
        ##$(".select_scope").prepend("<option scope-id='#{scope.get('id')}' value='#{scope.get('host')}.#{scope.get('domain')}'> #{scope.get('host')}.#{scope.get('domain')} </option> ")
        #children_num = $(".chzn-results").children().length
        #$(".chzn-results").append("<li style=\"\" class=\"active-result result-selected\" id=\"selWZW_chzn_o_#{children_num}\">#{scope.get('host')}.#{scope.get('domain')}</li>")
        #$(".select_scope").chosen()
        #$(".chzn-select").chosen() ##
        #$(".chzn-select").trigger("liszt:updated")
        #form.find(".chzn-select").trigger("liszt:updated"); 
        ##$(".select_scope").val(scope.get('host'))
        ##$(".select_scope").change()
        ##$(".select_scope").chosen()
        #$(".select_scope").hide()
        scopes = new Dnscell.Collections.Scopes()
        scopes.fetch
          data: { zone_id: $("#zone_data").data('zone').id }
          success: =>
            share_tab_view = new Dnscell.Views.share_tab(zone: @options.zone, host: @options.host, scopes: scopes)
            $(".content_inside").html( share_tab_view.render().el )
            Dnscell.Views.share_tab.prototype.render_share_tab_content()
        show_notice("Scope created.")

      error: @handleError

  handleError: (entry, response) =>
    if response.status == 422
      errors = $.parseJSON(response.responseText).errors
      formError = new Dnscell.Views.FormError(collection: errors)
      @$("#error_explanation").remove()
      @$(".item:visible > .modal-body").prepend("<div id='error_explanation'></div>")
      @$("#error_explanation").html(formError.render().el)