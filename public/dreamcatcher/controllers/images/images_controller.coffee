$.Controller 'Dreamcatcher.Controllers.Images.Images',

  model: Dreamcatcher.Models.Image
  
  init: ->
    @showWidget 'browser'
    @showWidget 'dropbox'
  
    
  showWidget: (widget, images, params, hideBrowser) ->
    $('#frame.browser').hide() if hideBrowser
    
    switch widget
    
      when 'browser'
        @browser = new Dreamcatcher.Controllers.Images.Browser $("#frame.browser") if not @browser
        @browser.parent = this
        @browser.show params.refresh, params.showSearch if params?
    
      when 'dropbox'
        @dropbox = new Dreamcatcher.Controllers.Images.Dropbox $("#dropbox") if not @dropbox
        @dropbox.parent = this
        @dropbox.show()
        
      when 'slideshow'
        @slideshow = new Dreamcatcher.Controllers.Images.Slideshow $("#slideshow-back") if not @slideshow?
        @slideshow.parent = this
        imageId = params.imageId if params? and params.imageId?
        @slideshow.show images, imageId
      
      when 'searchOptions'
        @searchOptions = new Dreamcatcher.Controllers.Images.SearchOptions $("#searchOptions") if not @searchOptions?
        @searchOptions.parent = this
        @searchOptions.show params
      
      when 'manager'
        @manager = new Dreamcatcher.Controllers.Images.Manager $("#frame.manager") if not @manager?
        @manager.parent = this
        title = params.title if params? and params.title?
        @manager.show images, title
  
  getImagesFromElements: (elements) ->
    images = []
    elements.each (i,el) =>
      images[i] = $(el).data 'image'
    return images
      
  showBrowser: (refresh, showSearch) ->
    @showWidget 'browser', null, {
      refresh: refresh
      showSearch: showSearch
    }
  
  showDropbox: ->
    @showWidget 'dropbox'
    
  showSearchOptions: (params) ->
    @showWidget 'searchOptions', null, params
    
  showSlideshow: (type, imageId, album) ->
    elements = @getImageElements type, album
    images = @getImagesFromElements elements
    @lazyLoad '#slideshow-back', 'images/slideshow', 'slideshow', images, { imageId: imageId }
    
  showManager: (type, title, album) ->
    elements = @getImageElements type, album
    images = @getImagesFromElements elements
    @lazyLoad '#frame.manager', 'images/manager', 'manager', images, { title: title }
      
  lazyLoad: (selector, path, widget, images, params) ->
    if not $(selector).exists()
      @model.getHtml path, {}, (html) =>
        $('body').append html
        @showWidget widget, images, params, true
    else
      @showWidget widget, images, params, true
      
  #called from within browser
  addImageToDropbox: (el) ->
    @dropbox.addImage el
    
  setDropboxImages: (elements) ->
    @dropbox.setImages elements
    
  registerDroppable: (el) ->
    @dropbox.registerDroppable el
  
  registerDraggable: (el, fromDropbox) ->
    @dropbox.registerDraggable el, fromDropbox
    
  getSearchOptions: ->
    options = {}
    options = @searchOptions.get() if @searchOptions?
    options['q'] = $(".searchField input[type='text']").val()
    return options
  
  'image.updated subscribe': (called, imageId) ->
    imageId = parseInt imageId
    @model.get imageId, {}, @callback('updateImageMeta', imageId)
    
  ###
  'image.started subscribe': (called) ->
    @browser.showSpinner()
  
  'image.stopped subscribe': (called) ->
    @browser.hideSpinner()
  ###
  
  #todo refactor
  
  updateImageMeta: (imageId, imageMeta) ->
    @getImageElements().each (i, el) =>
      id = parseInt $(el).data 'id'
      if imageId is id
        $(el).data 'image', imageMeta
    
  getImageElements: (type, album) ->
    switch type
      when 'artist' then return $('#albumList .img')
      when 'album' then return $("#albumList tr.images[data-album='#{album}'] .img")
      when 'dropbox' then return $('#dropbox li')
      when 'searchResults' then return $('#searchResults li')
    return $('#albumList .img,#dropbox li,#searchResults li')