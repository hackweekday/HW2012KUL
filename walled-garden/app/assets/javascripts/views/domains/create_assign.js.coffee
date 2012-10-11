class Dnscell.Views.CreateAssign extends Backbone.View
  template: JST['domains/create_assign']

  events:
    'submit #assign_form': 'createAssign'
    'click #close_assign': 'closeForm'

  render: ->
  #$("#modal").html( $(@el).html( @template( zone: @options.zone, host: @options.host ) ) ).modal()
    $(@el).html( @template(zone: @options.zone) )
    this

  closeForm: (event) ->
    event.preventDefault()
    $("#modal").modal("hide")

  createAssign: (event) =>
    event.preventDefault()
    scope = new Dnscell.Models.UserScopeAssign()
    attributes = 
      domain: $("#current_domain").html()
      email: $('#assign_email').val()
    scope.save attributes,
      wait: true
      success: =>
        $("#assign_form")[0].reset()
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
        s = new Backbone.Model()
        s.url = '/api/user_scope_assign?id=' + domain2url( scope.get('combine') ) + '&user_id=' + scope.get('user_id')
        s.fetch
          wait:true
          #data: { id: domain2url( scope.get('combine') ), user_id: scope.get('user_id') }
          #wait: true
          success: =>
            #console.log(s.toJSON());
            #w = s.toJSON()
            #console.log(w.combine);
            #scope = new Dnscell.Models.Host(id: domain2url(zone.get('zone_name')))
            #scope = new Dnscell.Collections.UserScopeAssigns()
            #share_tab_view = new Dnscell.Views.share_tab(zone: @options.zone, host: @options.host, scopes: scopes)
            #$(".content_inside").html( share_tab_view.render().el )
            #Dnscell.Views.share_tab.prototype.render_share_tab_content()
            ##assign_tab_view = new Dnscell.Views.assign_tab(zone: @options.zone, scopes: scopes)
            ##$("#scope_view").html( assign_tab_view.render().el )
            
            
            $('.assign_table tbody').append('<tr id="'+s.get('user_id')+'"><td>'+s.get('name')+'</td><td>'+s.get('email')+'</td><td>'+s.get('status')+'</td><td>'+s.get('created_at')+'</td><td><a class="btn_icon delete_icon delete_assign" id="'+s.get('user_id')+'" original-title="Delete" href="#">Delete</a></td></tr>')
            if $('.assign_table tr').size()-1 == 1
                $('.assign_table').show()
                $('.assign_pic').hide()
            $('tbody tr:last').effect("highlight", {}, 8000);
            #Dnscell.Views.assign_tab.prototype.render()
            #$('<tr><td>Test</td><td>Test</td><td>Test</td></tr>').insertAfter('#tbody_assign tr:last').effect("highlight", {}, 3000);
        show_notice("Assign is OK.")
      error: @handleError

  handleError: (entry, response) =>
    if response.status == 422
      errors = $.parseJSON(response.responseText).errors
      formError = new Dnscell.Views.FormError(collection: errors)
      @$("#error_explanation").remove()
      @$(".item:visible > .modal-body").prepend("<div id='error_explanation'></div>")
      @$("#error_explanation").html(formError.render().el)