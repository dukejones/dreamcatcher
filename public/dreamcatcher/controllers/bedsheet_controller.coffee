$.Controller 'Dreamcatcher.Controllers.Bedsheet',
    
  loadGenre: (genre) ->
    #TODO: showloading - perhaps use ajax:beforeSend, ajax:success?
    Dreamcatcher.Models.Bedsheet.findAll({}, @callback('populate'))
  
  populate: (bedsheets) ->
    $("#bedsheetScroller ul").html(@view('list',{bedsheets: bedsheets}))
    #TODO: hide loading...
    
  highlightBedsheet: (el) ->
    $(".bedsheet").removeClass("selected")
    el.addClass("selected")


  '.bedsheet click': (el) ->
    bedsheetId = el.data('id')
    $('#body').css('background-image', "url('/images/uploads/#{bedsheetId}-bedsheet.jpg')")
    @highlightBedsheet el  
    
    @options.parent.updateAppearanceModel(
      bedsheet_id: bedsheetId
    )

