$.Controller 'Dreamcatcher.Controllers.ImageBank.Dropbox',

  model: Dreamcatcher.Models.Image  
  getView: (url, data, type) ->
    type = 'dropbox' if not type?
    return @view "//dreamcatcher/views/image_bank/#{type}/#{url}.ejs", data

  init: ->
    
    $('#dropbox .imagelist').html ''
    @imageCookie = new Dreamcatcher.Classes.CookieHelper 'ib_dropbox'
    @stateCookie = new Dreamcatcher.Classes.CookieHelper 'ib_state', true
    @showImage imageId for imageId in @imageCookie.getAll() if @imageCookie.getAll()?

    $("#dropbox").offset @stateCookie.get() if @stateCookie.get()?
  
    # for adding images
    $("#dropbox").droppable {
      drop: (ev, ui) =>
        @addImage ui.draggable
    }

    # for removing images
    $('#bodyClick').droppable {
      drop: (ev, ui) =>
        @removeImage ui.draggable
    }

    $("#dropbox").draggable {
      cursor: 'grabbing'
      handle: 'h2,.icon'
      stop: (ev, ui) =>
        @stateCookie.set ui.position
    }
    

  
  show: ->
    $('#dropbox').show()
    
  clearImages: ->
    @imageCookie.clear()
    $('#dropbox .imagelist').html ''
  
  addImage: (el) ->
    imageId = el.data 'id'
    imageMeta = el.data 'image'
    if not imageId?
      log 'error with image'
    else if not @imageCookie.contains imageId
      @imageCookie.add imageId
      @showImage imageId, imageMeta
    else
      log 'already here' #todo - something better
      
  setImages: (elements) ->
    elements.each (i, el) =>
      @addImage $(el)

  removeImage: (el) -> 
    @imageCookie.remove el.data 'id'
    el.remove()
    
  showImage: (imageId, imageMeta) ->
    if imageMeta?
      $("#dropbox .imagelist").append @getView 'image', { image: imageMeta }
      @registerDraggable $('#dropbox .imagelist li:last'), true
    else
      @model.get imageId, {}, @callback('showImage', imageId)
      
      
  registerDraggable: (el, fromDropbox) ->
    el.draggable {
      containment: 'document'
      helper: 'clone'
      cursor: 'grabbing' # todo
      zIndex: 100
      start: (ev, ui) =>
        if fromDropbox
          $("#dropbox").css('z-index', '1100') # look at styles
          $("#bodyClick").show()
      stop: (ev, ui) =>
        if fromDropbox
          $("#dropbox").css('z-index', '') #  look at styles
          $("#bodyClick").hide()
    }
  
  registerDroppable: (el) ->
    el.droppable {  
      drop: (ev, ui) =>  
        dropTo = $(ev.target).parent()
        album = dropTo.data 'album'
        imageMeta = ui.draggable.data 'image'
        return if imageMeta.album is album
        imageId = ui.draggable.data 'id'
        
        @model.update imageId, {image: {album: album} }, (imageId, album) =>
          ui.draggable.appendTo $('td', dropTo)
          imageMeta = ui.draggable.data 'image'
          imageMeta.album = album
          ui.draggable.data 'image', imageMeta
          @registerDraggable ui.draggable, false
    }
    
  '.cancel click': (el) -> #TODO: fix
    @clearImages()
  
  '.manage click': (el) ->
    @parent.showManager 'dropbox', 'Drop box'
  
  'li .close click': (el) ->
    @removeImage el.parent()
  
  '.play click': (el) ->
    @parent.showSlideshow 'dropbox'
    
  'li img dblclick': (el) ->
    imageId = el.parent().data 'id'
    @parent.showSlideshow 'dropbox', imageId