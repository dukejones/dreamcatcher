$.Controller 'Dreamcatcher.Controllers.Application',

  init: ->
    @metaMenu = new Dreamcatcher.Controllers.MetaMenu $('.rightPanel') if $('.rightPanel').exists()
    @comment = new Dreamcatcher.Controllers.Comment $('#entryField') if $('#entryField').exists()
    @ibManager = new Dreamcatcher.Controllers.IbManager $("#frame.manager") if $("#frame.manager").exists()
    @ibBrowser = new Dreamcatcher.Controllers.IbBrowser $("#frame.browser") if $("#frame.browser").exists()

  #TODO: Possibly refactor into jQuery syntax, and remove all other versions.
  fitToContent: (id, maxHeight) ->
    text = if id and id.style then id else document.getElementById(id)
    return 0 if not text
    adjustedHeight = text.clientHeight
    if not maxHeight or maxHeight > adjustedHeight
      adjustedHeight = Math.max(text.scrollHeight, adjustedHeight)
      adjustedHeight = Math.min(maxHeight, adjustedHeight) if maxHeight
      text.style.height = adjustedHeight + 80 + 'px' if adjustedHeight > text.clientHeight    

  '#bodyClick click': ->
    @metaMenu.hideAllPanels() if @metaMenu? #use subscribe/publish?
    
  #TODO: eventually remove '.comment_body' to apply to all 'textarea's
  '.comment_body keyup': (el) ->
    @fitToContent el.attr("id"),0
    
  '.button.appearance click': (el) ->
    @metaMenu.selectPanel 'appearance'
    
  '.addTheme .img click': (el) ->
    @metaMenu.selectPanel 'appearance'

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')