$.Class 'UiHelper',{
  
  registerTooltip: (el) ->
    left = el.hasClass 'left'
    el.tooltip {
      track: true
      delay: 0
      showURL: false
      showBody: ' - '
      fade: 250
      positionLeft: left
      top: 20 if left
    }
    
  registerSelectMenu: (el) ->
    id = el.attr 'id'
    
    dropdown = el.hasClass 'dropdown'
    radio = el.hasClass 'radio'
    offset = el.hasClass 'offset'
    
    
    options = {
      style: 'popup'
      menuWidth: '200px'
    }
    
    if dropdown
      $.extend options, {
        style: 'dropdown'
        positionOptions:
          offset: "0px -37px"
      }
      
    if offset
      $.extend options, {
        menuWidth: '164px'
        positionOptions: {
          offset: '-126px -35px'
        }
      }
    
    if radio
      defaultName = el.data 'default-name'
            
      $.extend options, {
        menuWidth: '156px'
        format: (text) =>
          return $.View '/dreamcatcher/views/common/select_menu_format.ejs', {
            text: text
            value: text
            name: defaultName
          }
      }  
    
    el.selectmenu options
    #log options

    if radio
      defaultValue = el.data 'default-value'
      $("##{id}-menu label.ui-selectmenu-default").each (i, el) ->
        li = $(el).closest('li')
        value = $('a',li).data 'value'
        isDefault = value is defaultValue
        li.addClass 'default' if isDefault

        # checks the radio button if it's the default value
        $('input[type="radio"]',el).attr 'checked', isDefault

        # moves the radio button outside the a tag (so it doesn't conflict)
        $(el).appendTo li
    
},{}