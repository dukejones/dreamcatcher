$.Model 'Dreamcatcher.Models.Admin',{
  
  loadUsers: ( params, success, error ) ->
    $.ajax {
      url: "/admin/user_list"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    } 

  loadChart: ( params, success, error ) ->
    $.ajax {
      url: "/admin/charts"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    }
    
},
{}