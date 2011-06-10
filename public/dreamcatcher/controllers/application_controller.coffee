$.Controller 'Dreamcatcher.Controllers.Application',
  
  #- constructor
  
  init: ->
    @setupControllers()
    @publish 'dom.added', $('#body') 
    
  #- controllers
  
  setupControllers: ->
    @metaMenu   = new Dreamcatcher.Controllers.Users.MetaMenu     $('#metaMenu')        if $('#metaMenu').exists()
    @images     = new Dreamcatcher.Controllers.ImageBank          $("#frame.browser")   if $("#frame.browser").exists()
    @entries    = new Dreamcatcher.Controllers.Entries            $("#entryField")      if $("#entryField").exists()
    @admin      = new Dreamcatcher.Controllers.Admin              $('#adminPage')       if $('#adminPage').exists()
        
  #- setup ui elements
  
  initUi: (parentEl) ->
    parentEl = $('body') if not parentEl?
    $('.tooltip', parentEl).each (i, el) =>
      Dreamcatcher.Classes.UiHelper.registerTooltip $(el)
    $('.select-menu', parentEl).each (i, el) =>
      Dreamcatcher.Classes.UiHelper.registerSelectMenu $(el)
    $('textarea', parentEl).each (i, el) =>
      fitToContent $(el).attr('id'), 0
      
  'dom.added subscribe': (called, data) ->
    @initUi data
    
  #- appearance (bedsheet, scroll  & theme) change
  
  'appearance.change subscribe': (called, data) ->
    #if no data is passed, then use the user default settings
    if not data?
      data = $('#userInfo').data 'viewpreference'

    return if not data.image_id?

    bedsheetUrl = "/images/uploads/#{data.image_id}-bedsheet.jpg"
    return if $('#backgroundReplace').css('background-image').indexOf(bedsheetUrl) isnt -1

    #todo: should include font size & float?
    if data.bedsheet_attachment?
      $('#body').removeClass('scroll fixed')
      $('#body').addClass data.bedsheet_attachment
    if data.theme?
      $('#body').removeClass('light dark')
      $('#body').addClass data.theme

    img = $("<img src='#{bedsheetUrl}' style='display:none' />")
    $(img).load ->
      $('#bedsheetScroller .bedsheet .spinner').remove() #remove if exists
      #todo: make style
      $('#backgroundReplace').css 'background-image', "url('#{bedsheetUrl}')"
      $('#backgroundReplace').fadeIn 1000, =>
        $('#backgroundReplace').hide()
        $('#body').css 'background-image', "url('#{bedsheetUrl}')"
    $('body').append img
    
  #- catch any body click event

  '#bodyClick click': ->
    @publish 'body.clicked'
    
  #- fit to content event
    
  'textarea keyup': (el) ->
    fitToContent el.attr('id'), 0
    
  '.button.appearance, #entry-appearance click': (el) -> #todo: merge class name
    @publish 'menu.show', 'appearance'
  
  #- select-menu events - todo: move into own controller?
    
  'label.ui-selectmenu-default mouseover': (el) ->
    el.parent().addClass 'default-hover'

  'label.ui-selectmenu-default mouseout': (el) ->
    el.parent().removeClass 'default-hover'  
  
  '.ui-selectmenu-default input[type=radio] click': (el) ->
    # radio button check for select-menu
    #todo: publish
    ul = $(el).closest 'ul'
    $('li', ul).removeClass 'default'
    $(el).closest('li').addClass 'default'
    
    name = el.attr 'name'
    value = $('a:first',el.closest('li')).data 'value'
    
    user = {}
    user[name] = value
    Dreamcatcher.Models.User.update {user: user}
  
  
$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')