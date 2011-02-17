sharingController = null

$(document).ready ->
  sharingController = new SharingController('.sharing')



class SharingController
  constructor: (containerSelector)->
    @$container = $(containerSelector)
    @$dropdown = @$container.find('#entry_sharing_level')
    
    @sharingView = new SharingView(containerSelector)
    @shareSettings = new Share()
    
    @$container.find('.listSelection').click( (event) =>
      currentSelection = @$dropdown.val()
      @sharingView.changeView(currentSelection)
    )
    
    @$dropdown.change( (event) =>
      newSelection = @$dropdown.val()
      log newSelection
      @sharingView.changeView(newSelection)
      @shareSettings = new Share(newSelection)
    )


class SharingView
  constructor: (containerSelector, type = 'everyone')->
    @$container = $(containerSelector)
    @type = type
  
  changeView: (type) ->
    @type = type
    
    # Hide all items
    @$container.find('.target').hide()
    
    # Remove any bodyclick & create a new one
    $('#bodyClick').remove()
    bodyClick = '<div id="bodyClick" style="z-index: 1100; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>'
    $('body').prepend(bodyClick)
  
    #$('html, body').animate({scrollTop:0}, 'slow');
  
    $('#bodyClick').click( (event) =>
      @$container.find('.target').hide()
      $('#bodyClick').remove()
    )
    
    # logic to update the visual display
    switch @type
      when "500" # Everyone
        @$container.find('.everyone').slideDown()
      when "list of users"
        @$container.find('.listOfUsers').slideDown()

# Sharing Model
class Share
  constructor: (type = 'everyone') ->
    @type = type
    
    # example settings object
    @settings = 
      everyone:
        facebook: false
        twitter: false
      list:
        friends: false
        followers: false
        users: [] # Array of user_id's
  
  type: -> @type
  addUser: (user_id) ->
    @settings.list.users.push user_id