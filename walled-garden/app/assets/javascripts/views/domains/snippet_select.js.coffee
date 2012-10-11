class Dnscell.Views.snippet_select extends Backbone.View

  template: JST['domains/snippet_select']

  render: ->
  	$(@el).html(@template(snippets: @collection))
  	this

  events:
    "change .snippet_selector": "snippet_change"
    "click .process_snippet": "process_snippet"

  snippet_change: (e) =>
  	snippet_id = $(e.currentTarget).val()
  	snippet_records = new Backbone.Collection()
  	snippet_records.url = '/api/snippets/records?snippet_id=' + snippet_id
  	snippet_records.fetch
      success: (data) =>
        $(".snippet_records").html("")
        $.each snippet_records.models, (i,v) =>
          $(".snippet_records").append "
          <div class='snippet_list'>
	          <input type=checkbox name='record_#{v.get('id')}' id='record_#{v.get('id')}' #{'checked=checked' if v.get('checked') == true} > 
	          <label for='record_#{v.get('id')}'> 
	          	<span class='rr_type'> #{v.get('record_type')} </span> 
              <span class='host_name'> #{v.get('record_host').replace('<domain_name>', $("#current_domain").html() )}</span> &mdash;	
	          	<span class='content'> #{v.get('content')} </span>
	          </label>
	        </div>
          "

  process_snippet: (e) =>
    e.preventDefault()
    data = {}
    data["snippet_records_id"] = 
    	_.map $("input[name^=record_]:checked"), (x) ->
        x.name.replace "record_", ""
    data["host_id"] = $("#domain_id").val()
    $.ajax
      url: '/api/snippets/process_snippet'
      data: data
      dataType: "json"
      success: (data) =>
      	$("#modal").modal('hide')
      	show_notice("Snippet Applied.")