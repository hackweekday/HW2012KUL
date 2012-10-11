class Dnscell.Views.FormError extends Backbone.View
  tagName: 'ol' 

  template: JST['domains/form_error']

  render: ->
    console.log "00"
    console.log @collection.length
    console.log "00"
    
    counter = 0
    for attribute, messages of @collection
      for message in messages
        counter += 1

    $(@el).html(@template(errors: @collection, errors_number: counter))
    this

  deleteDomain: (event) ->
    event.preventDefault()

