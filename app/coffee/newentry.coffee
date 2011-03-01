
$(document).ready ->
  tagsController = new TagsController('.entryTags', 'edit')
  
  # Setup tag re-ordering
  $("#sorting").val(1)
  $("#tag-list").sortable -> distance: 30
		
	$( "#tag-list" ).bind "sortstart", (event, ui) ->
	  $("#sorting").val(0)
	  
	$( "#tag-list" ).bind "sortstop", (event, ui) ->
	  $("#sorting").val(1)
	  
	  # ONLY update tag sorting if editing an entry
	  if $('#entryField > form').hasClass('edit_entry')
	    tagOrder = []
  	  $('#tag-list > .tag').each (i, el) ->
  	    tagOrder.push($(this).data('id'))
	    
  	  entry = $('#showEntry').data('id')
  	  order = tagOrder.join()
  
  # Setup icon type changing
  $('#entryType_list').unbind();
  $('#entryType_list').change( ->
    newIcon = $(this).find('option:selected').css('background-image')
    newIconSrc = newIcon.slice(5, newIcon.length - 2)
    
    # get the larger icon path
    largeSelectionImage = newIconSrc.slice(0, newIconSrc.length-6) + '32.png'
    
    $(this).prev().attr('src', largeSelectionImage)
  )
  $('#entryType_list').change()
  
  # Hide the elements in the browsers they cant be seen in
  if window.BrowserDetect.browser is "Safari" or window.BrowserDetect.browser is "Chrome"
    $('.typeSelection, .listSelection').hide()
    $('.entryType').css('border', 'none')
    