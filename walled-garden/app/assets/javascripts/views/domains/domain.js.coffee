class Dnscell.Views.Domain extends Backbone.View
  tagName: 'li' 

  template: JST['domains/domain']

  events:
    'click': 'domain_selected'
    'click #delete_domain': 'deleteDomain'

  render: ->
    #alert @model.get('combine')
    #alert 'domain ' + domain.get('combine')
    #$(@el).html(@template(entry: @model))
    #this.id = this.model.id;
    $(@el).attr('id', "domain_#{@model.get('id')}" ).html(@template(domain: @model))
    #$("#domain_id").attr("id","domain_#{@model.get('combine')}");
    this

  domain_selected: (event) =>
    # @$("li").addClass('bedo')
    event.preventDefault()
    #alert @model.get('id')
    if $("#domains > li.current").attr("id") != "domain_#{@model.get('id')}"
      $("#domains > li.current").removeClass("current")
      $("#current_domain").html("#{@model.get('combine')}")
      # console.log $("#domain_#{@model.get('id')}").parent()
      $('.host_list').html("Loading..")
      $("#domain_id").val( @model.get('id') )
      # $(".new_subdomain").attr("href", "/subdomains/new")

      # @count = ""
      # $.ajax({
      #   url: "/api/hosts/count?host_id=" + domain2url(@model.get('reference1'))
      #   success: (count) =>
      #     alert count
      #   })

      Backbone.history.navigate("apps_management/domains/#{@model.get('combine')}".replace(/\./g, '_') , true)

  deleteDomain: (event) ->
    event.preventDefault()   
