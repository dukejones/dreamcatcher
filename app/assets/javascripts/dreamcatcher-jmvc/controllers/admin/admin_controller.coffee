$.Controller 'Dreamcatcher.Controllers.Admin.Admin', {
  pluginName: 'admin'
}, {
  
  init: -> 
    @page = 1
    @bedsheetsLoaded = false   
    @totalUsers = parseInt $('#totalUsers').data 'id'
    @pageSize = $('#pageSize').data 'id'
    @totalPages = Math.ceil(@totalUsers / @pageSize)    
    @addPageLinks()
    @updateNav()
    @scope = 'None'
    @charts = new Dreamcatcher.Controllers.Admin.Charts $('#adminPage'),{parent: this}
    @charts.getLineChartData('last 7 days in users','user')
    @charts.getLineChartData('last 7 days in entries','entry')
   
   
  updateUsersPage: (json) ->  
    $('#users').html(json.html)
    $('#allUsersIcon').show()
    $('#user-pageLoading').hide()

  
  # Show or hide next/prev buttons
  updateNav: ->
    if @page > 1 
     $('#prevPage').show()
     $('#prevPageEnd').hide()
    else 
     $('#prevPage').hide()
     $('#prevPageEnd').show()

    if @page < @totalPages    
      $('#nextPage').show()
      $('#nextPageEnd').hide()
    else
      $('#nextPage').hide()
      $('#nextPageEnd').show()
      
    $(".userPage").css("text-decoration", "none") # reset
    $("#userPage-#{@page}").css("text-decoration", "underline")   
  
  displayBedsheets: ( bedsheetsLoaded, json) ->   
    unless @bedsheetsLoaded
      $('#bedsheet-nodes').html(json.html)
      @bedsheetsLoaded = true
    
  # Add numbered page links  
  addPageLinks: ->
    num = 0
    while num < @totalPages
      num += 1
      $('#pages').append $.View '/dreamcatcher/views/admin/page_number.ejs', {page: num}    

  # Generate model options   
  getOptions: ->
    filters: {
      page: @page
      order_by: $('#user-filter').val()
    }

  togglePanel: (wrapperId,arrowId) ->
    $("##{wrapperId}").toggle('showHide')

    $userChartArrow = $("##{arrowId}")   
    if $userChartArrow.hasClass('up')
      $userChartArrow.removeClass('up').addClass('down')
    else
      $userChartArrow.removeClass('down').addClass('up')    
    
  # --- DOM listeners ---
  
  '.userPage click': (el,ev) ->
    @page = parseInt el.text()
    $('#allUsersIcon').hide()
    $('#user-pageLoading').show()
    Dreamcatcher.Models.Admin.loadUsers @getOptions(), @updateUsersPage
    @updateNav()     

  '#nextPage, #prevPage click': (el,ev) ->
    @page = 1 if !@page? 
    @page = if ev.currentTarget.id is 'nextPage' then @page += 1 else @page -= 1 
    $('#allUsersIcon').hide()
    $('#user-pageLoading').show()
    Dreamcatcher.Models.Admin.loadUsers @getOptions(), @updateUsersPage  
    @updateNav() 
    
  '#user-filter change': (el) ->
    @page = 1 
    $('#user-pageLoading').show()
    Dreamcatcher.Models.Admin.loadUsers @getOptions(), @updateUsersPage  
    @updateNav()    
    
  '#userCharts click': ->
    @togglePanel('userCharts-wrap','userCharts-arrow')

  '#userList click': ->
    @togglePanel('userList-wrap','userList-arrow')
    
  '#entryCharts click': ->
    @togglePanel('entryCharts-wrap','entryCharts-arrow')   

  '#bedsheets.panel click': ->
    Dreamcatcher.Models.Admin.loadBedsheets @getOptions(), @callback('displayBedsheets', @bedsheetsLoaded)
    @togglePanel('bedsheet-nodes','bedsheets-arrow')

  '#searchButton click': (el)->
    el.val('') if el.val() is 'search users'

  '#searchButton mouseout': (el)->
    el.val('search users') if el.val() is ''

  '.button click': (el,ev) ->
    # the google.load command needs to be loaded in resources/google.charts.coffee so that it gets loaded before this controller

    $buttonParent = $("##{ev.currentTarget.id}").parent()
    buttonType = 'user' if $buttonParent.hasClass('userButton-border') 
    buttonType = 'entry' if $buttonParent.hasClass('entryButton-border')

    if ev.currentTarget.id is 'users-1wk' then google.setOnLoadCallback @charts.getLineChartData('last 7 days in users', buttonType)
    if ev.currentTarget.id is 'users-8wks' then google.setOnLoadCallback @charts.getLineChartData('last 8 weeks in users', buttonType)    
    if ev.currentTarget.id is 'users-6months' then google.setOnLoadCallback @charts.getLineChartData('last 6 months in users', buttonType)
    if ev.currentTarget.id is 'users-entries' then google.setOnLoadCallback @charts.getPieChartData('top 32 users by entries', buttonType)
    if ev.currentTarget.id is 'users-starlight' then google.setOnLoadCallback @charts.getPieChartData('top 32 users by starlight', buttonType)
    if ev.currentTarget.id is 'users-seeds' then google.setOnLoadCallback @charts.getPieChartData('seed codes usages', buttonType)

    if ev.currentTarget.id is 'entries-1wk' then google.setOnLoadCallback @charts.getLineChartData('last 7 days in entries', buttonType)
    if ev.currentTarget.id is 'entries-8wks' then google.setOnLoadCallback @charts.getLineChartData('last 8 weeks in entries', buttonType)
    if ev.currentTarget.id is 'entries-6months' then google.setOnLoadCallback @charts.getLineChartData('last 6 months in entries', buttonType)
    if ev.currentTarget.id is 'entries-entry_types' then google.setOnLoadCallback @charts.getLineChartData('last 6 months in entry types', buttonType)
    if ev.currentTarget.id is 'entries-comments' then google.setOnLoadCallback @charts.getLineChartData('last 6 months in comments', buttonType)
    if ev.currentTarget.id is 'entries-tags' then google.setOnLoadCallback @charts.getPieChartData('top 32 tags', buttonType)
    
    $(".#{buttonType}Button-border").removeClass('select') # reset all buttons for this buttonType
    $buttonParent.addClass('select')

}


    
    