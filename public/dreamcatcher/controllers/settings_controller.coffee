$.Controller 'Dreamcatcher.Controllers.Settings',

  init: ->
    @setupDefaults()
    @setupAjaxBinding()
    
  setupDefaults: ->
    sharingLevel = $('#settingsPanel .defaultSharing').data 'id'
    $('#sharingList').val(sharingLevel) 
    @displaySharingLevel sharingLevel
    
  showPanel: ->    
    $('#settingsPanel').show()

  displaySharingLevel: (sharingLevel) ->
    #TODO: after SASS refactor, replace with class
    sharingLevel = parseInt sharingLevel
    switch sharingLevel
      when 500 then background = 'sharing-24-hover.png'
      when 200 then background = 'friend-24.png'
      when 150 then background = 'friend-24-follower.png'
      when 50 then background = 'anon-24-hover.png'
      when 0 then background = 'private-24-hover.png'

    $('.sharing-icon').css "background","url(/images/icons/#{background}) no-repeat center transparent"

  displayLandingPage: (landingPage) ->
    #TODO: after SASS refactor, replace with class
    switch landingPage
      when 'stream' then background = 'stream-24-hover.png'
      when 'home' then background = 'home-24-hover.png'
      when 'today' then background = 'home-24-hover.png'
    
    $('.landing-icon').css "background","url(/images/icons/#{background}) no-repeat center transparent"
    
  updateSettingsModel: (params) ->
    Dreamcatcher.Models.Settings.update params

  setupAjaxBinding: ->
    #TODO: Needs refactoring.
    $('#fbLink').bind 'ajax:success', (event, xhr, status)->
      $('#fbLink').remove()
      $('.network').append '<a id="fbLink" href="/auth/facebook" class="linkAccount">link account</a>'

    $('form#change_password').bind 'ajax:beforeSend', (xhr, settings)->
      $('.changePassword .target').hide()

    $('form#change_password').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text xhr.message
      if xhr.errors
        for error, message of xhr.errors
          $('#user_' + error).prev().text message[0]
        $('.changePassword .target').slideDown 250
      else
        $('#change_password .error').text ''
        $('#user_old_password, #user_password, #user_password_confirmation').val ''

    $('form#change_password').bind 'ajax:error', (xhr, status, error)->
      log xhr.errors
    
    
  '#sharingList change': (el, ev) ->
    sharingLevel = el.val()
    @displaySharingLevel sharingLevel
    @updateSettingsModel {'user[default_sharing_level]': parseInt sharingLevel}

  '#landingPage change': (el, ev) ->
    landingPage = el.val()
    @displayLandingPage landingPage
    @updateSettingsModel {'user[default_landing_page]': landingPage}   

  '.cancel click': ->
    $('.changePasswordForm').hide()
    $('#user_password,#user_password_confirmation').val ''
