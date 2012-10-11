class Dnscell.Views.short_urls extends Backbone.View

  template: JST['hosts/short_urls']

  render: ->
    $(@el).html(@template(host: @model))
    this

  events:
    "click .new_shorturl":"new_shorturl"
    "click .edit_shorturl":"edit_shorturl"
    "click .delete_shorturl":"delete_shorturl"
    "click .delete_shorturls":"delete_shorturls"
    "click #delete_all_shorturl":"delete_all_shorturl"
    "submit #fast_shortner":"fast_shortner"

  new_shorturl: (e) =>
    e.preventDefault()
    shorturl = new Dnscell.Models.short_url()
    sV = new Dnscell.Views.shorturl_form(model: @model, shorturl: shorturl)
    $("#record_form").html(sV.render().el)
    $("#record_form").modal()

  edit_shorturl: (e) =>
    e.preventDefault()
    console.log $(e.currentTarget)
    data = $(e.currentTarget).nextAll('.shorturl_data').data('shorturl')
    shorturl = new Dnscell.Models.short_url( data )
    sV = new Dnscell.Views.shorturl_form(model: @model, shorturl: shorturl)
    $("#record_form").html(sV.render().el)
    $("#record_form").modal()

  delete_shorturl: (e) =>
  	e.preventDefault()
  	if confirm "Are you sure?"
	    data = $(e.currentTarget).next('.shorturl_data').data('shorturl')
	    shorturl = new Dnscell.Models.short_url( data )
	    shorturl.destroy()
	    $("#shorturls").dataTable().fnDraw()

  delete_shorturls: (e) =>
    e.preventDefault()
    ids = $("input[name^=shorturl]:checked").serialize()
    if ids.length > 0 && confirm "Are you sure?"
      $.ajax
        url: '/api/hosts/delete_shorturls'
        dataType: "json"
        type: "post"
        data: $("input[name^=shorturl]:checked").serialize()
        success: ->
        	$("#shorturls").dataTable().fnDraw()
        	show_notice("Short URL deleted.")
        	$("#delete_all_shorturl").attr('checked', false)
  
  delete_all_shorturl: ->
    if $("#delete_all_shorturl").is(":checked")
      $("input[name^=shorturl]:not(:disabled)").prop("checked", true)
    else
      $("input[name^=shorturl]").prop("checked", false)

  fast_shortner: (e) =>
    e.preventDefault()
    if $("#fast_shortner_url").val().match(/(http:\/\/|https:\/\/)/) == null
      destination = $("#fast_shortner_url").val()
      $("#fast_shortner_url").val( 'http://' + destination )

    $.ajax
      url: '/api/hosts/fast_shortner'
      type: "post"
      dataType: "JSON"
      data: "destination=#{escape($('#fast_shortner_url').val())}&host_id=" + $("#current_host_id").val()
      success: (data) =>
        $("#shorturls").dataTable().fnDraw()
        $("#fast_shortner .status").html("<span class='copy_url'></span> http://" + @model.get('combine') + '/' + data.shortcode)
        $("#fast_shortner .status").zclip('remove')
        $('#fast_shortner .status').zclip
          path: "/ZeroClipboard.swf"
          copy: =>
            "http://" + @model.get('combine') + '/' + data.shortcode
          # afterCopy: =>
          #   alert  "http://" + @model.get('combine') + '/' + data.shortcode
          #   show_notice("URL copied.")
        $("#fast_shortner .status").effect("pulsate", { times:3 }, 700);;
        $("#fast_shortner_url").val("")
        show_notice("Short URL created.")