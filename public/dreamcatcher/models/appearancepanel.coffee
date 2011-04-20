$.Model.extend('Dreamcatcher.Models.AppearancePanel',{  

  findAll: ( params, success, error ) ->
    $.ajax(
      url: '/images.json?section=Bedsheets'
      type: 'get'
      dataType: 'json'
      data: params
      success: @callback(['wrapMany',success])
      error: error
    )

  update: ( id, params, success, error ) ->
    url = "/user/set_view_preferences"
    #url = "/entries/#{id}/set_view_preferences" if id? #entry view is id is not null
    $.ajax(
      type: 'post'
      url: url
      data: params
      success: success
      error: error
    )
},
{})