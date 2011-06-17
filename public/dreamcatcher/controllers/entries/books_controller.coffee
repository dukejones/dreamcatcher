$.Controller 'Dreamcatcher.Controllers.Entries.Books', {
  pluginName: 'books'
}, {

  # Don't forget permissions on books

  model: {
    book: Dreamcatcher.Models.Book
    entry: Dreamcatcher.Models.Entry
  }
  
  el: {    
    bookMatrix: (id) ->
      return $("#entryField .matrix.bookIndex[data-id=#{id}]") if id?
      return $('#entryField .matrix.index') 
    book: (arg) ->
      return $(".book[data-id=#{arg}]", @element) if parseInt(arg) > 0
      return arg.closest '.book' if arg?
      return null
  }
  
  data: (el) ->
    return el.data type if type?
    return el.data 'id' if el?
    return null
    
    
  init: (el) ->
    @element = $(el)
    @publish 'book.drop', @element
    
    
  moveEntryToBook: (entryEl, bookEl) ->
    entryId = @data entryEl
    bookId = @data bookEl
    bookId = null if bookEl.parent().attr('id') is 'contextPanel'
    entryMeta = {book_id: bookId}

    @model.entry.update entryId, {entry: entryMeta}

    @publish 'books.close', bookEl
    bookMatrixEl = @el.bookMatrix bookId
    if bookMatrixEl.exists()
      entryEl.appendTo bookMatrixEl
    else
      entryEl.hide()

    $('.entryDrop-active', bookEl).hide()


  'book.drop subscribe': (called, parent) ->
    $('.book, .avatar', parent).each (i, el) =>
      @publish 'books.close', $(el)
      $(el).droppable {         
        drop: (ev, ui) =>
          dropEl = $(ev.target)
          @moveEntryToBook ui.draggable, dropEl

        over: (ev, ui) =>
          el = $(ev.target)
          @publish 'books.hover', el if el.hasClass 'book'
          $('.add-active', ui.helper).show()
          $('.entryDrop-active, .entryRemove', el).show()

        out: (ev, ui) =>
          el = $(ev.target)
          @publish 'books.close', el if el.hasClass 'book' 
          $('.add-active', ui.helper).hide()
          $('.entryDrop-active, .entryRemove', el).hide()
      }
  
  #- new book
    
  'books.create subscribe': ->
    @model.book.new {}, (html) =>
      $('#welcomePanel').hide()
      @element.prepend html
      bookEl = $('.book:first', @element)
      @editBook bookEl
      @publish 'dom.added', bookEl
    
  #- show book
  
  showBook: (bookId) ->
    bookEl = @el.book bookId    
    @publish 'context_panel.book', bookEl.clone().css 'z-index', 2000
    @publish 'book.drop', $('#contextPanel')

    @model.book.show bookId, {}, (html) =>
      $('#entryField').children().hide()
      bookMatrixEl = @el.bookMatrix bookId
      if bookMatrixEl.exists()
        bookMatrixEl.replaceWith html
      else
        $('#entryField').append html
      @publish 'entries.drag', bookMatrixEl

  'books.show subscribe': (called, data) ->
    @showBook data.id
    @publish 'appearance.change'

  #- open for edit
  editBook: (el) ->
    @openBook el, true
    
  'books.edit subscribe': (called, el) ->
    @editBook el
      
  '.closed .edit click': (el) ->
    @editBook el
  
  #- open 
  openBook: (el, edit) ->
    @closeAllBooks()
    bookEl = @el.book el
    $('.open, .closeClick', bookEl).show()
    $('.control-panel', bookEl).toggle edit
    $('.closed', bookEl).hide()
    
  'books.hover subscribe': (called, el) ->
    @openBook el, false
    
  #- close
  closeBook: (el) ->
    bookEl = @el.book el
    $('.open', bookEl).hide()
    $('.open', bookEl).children().hide()
    $('.closed', bookEl).show()
  
  'books.close subscribe': (called, el) ->
    @closeBook @el.book el

  '.closeClick, .confirm click': (el) ->
    @closeBook @el.book el
  
  #-- all
  
  closeAllBooks: (el) ->
    @closeBook()
  
  'body.clicked subscribe': (called, data) ->
    @closeAllBooks()
      
  #- paging
  
  showPage: (el, page) ->
    bookEl = @el.book el
    $('.open', bookEl).children().hide()
    $('.closeClick', bookEl).show()
    $(".#{page}-panel", bookEl).show() if page?
    
    @createUploader bookEl if page is 'cover'
        
  #-- panels
  
  '.book .control-panel .color click': (el) ->
    @showPage el, 'color'

  '.book .control-panel .coverImage click': (el) ->
    @showPage el, 'cover'

  '.book .control-panel .access click': (el) ->
    @showPage el, 'access'

  '.book .open .back click': (el) ->
    @showPage el, 'control'
    
  #-- more settings

  showMore: (el) ->
    bookEl = @el.book el
    $('.settings-basic', bookEl).toggle()
    $('.more-settings', bookEl).toggle()

  '.book .arrow click': (el) ->
    @showMore el    

  #- save book
  
  saveBook: (el, meta) ->
    bookEl = @el.book el
    bookId = @data bookEl
    params = {book: meta}
    if bookId is 'new'
      @model.book.create params, (data) =>
        bookEl.data 'id', data.book.id if data.book?
    else
      @model.book.update bookId, params
  
  #-- title

  saveTitle: (el) ->
    bookEl = @el.book el
    title = el.val()
    $('.title', bookEl).text title
    @saveBook el, { title: title }

  '.titleInput blur': (el) ->
    @saveTitle el

  '.titleInput keypress': (el, ev) ->
    @saveTitle el if ev.keyCode is 13 # enter key

  
  #-- color
  
  '.color-panel .swatches li click': (el) ->
    color = el.attr 'class'
    bookEl = @el.book(el).attr 'class', "book #{color}"
    @saveBook el, {color: color}
  
  #-- access
  
  '.access-panel .select-menu change': (el) ->
    meta = {}
    meta[el.attr('name')] = el.val()
    @saveBook el, meta
    
  #- disable book
    
  disableBook: (el) ->
    if confirm 'are you sure?'
      bookEl = @el.book el
      @model.book.disable @data bookEl
      bookEl.remove()
  
  '.more-settings .remove click': (el) ->
    @disableBook el
      
  #- uploader
    
  createUploader: (el) ->
    $('.cover-panel', el).uploader {
      singleFile: true
      params: {
        image: {
          section: 'book covers'
          category: 'all'
        }
      }
      classes: {
        button: 'add'
        drop: 'dropbox'
        list: 'dropbox-field-shine'
      }
      onSubmit: @callback('uploadSubmit', el)
      onComplete: @callback('uploadComplete', el)
    }
  
  uploadSubmit: (el, id, fileName) ->
    $('.dropbox-field-shine .add', el).hide()
  
  uploadComplete: (el, id, fileName, result) ->
    image = result.image
    if image?
      $('.uploading', el).remove()
      el.data 'image', image.id
      background = "url(/images/uploads/#{image.id}-252x252.#{image.format})"
      $('.cover, .dropbox-field-shine', el).css 'background-image', background
      $('.dropbox-field-shine li', el).remove() #todo: remove upload progress
      @saveBook el, { cover_image_id: image.id }
      
    $('.dropbox-field-shine .add', el).show()
    
}