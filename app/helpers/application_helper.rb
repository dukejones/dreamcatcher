module ApplicationHelper
  def avatar_image(user, size = :main)
    avatar_image = user._?.image || Image.default_avatar
    case size
    when :main
      avatar_image.url('avatar_main')
    when :medium
      avatar_image.url('avatar_medium')
    else
      avatar_image.url('avatar', :size => size)
    end
  end
  
  def friend_icon_tag(relationship, size, html_options={})
    html_options.merge!( size: "#{size}x#{size}", alt: relationship )
    image_tag( "icons/#{friend_icon(relationship, size)}", html_options)
  end
  
  def friend_icon(relationship, size)
    case relationship
    when :friends
      "friend-#{size}.png"
    when :following
      "friend-follow-#{size}.png"
    when :followed_by
      "friend-follower-#{size}.png"
    when :none
      "friend-none-#{size}.png"
    end
  end

  def follow_action(relationship)
    case relationship
    when :friends, :following
      "unfollow"
    when :followed_by, :none
      "follow"
    end
  end
  
  def is_ipad?
    request.user_agent.match(/iPad/)
  end
  
  def coffeescript_include_tag(*sources)
    javascript_include_tag(*(sources.map { |js| "compiled/#{js}" }))
  end
  
  def sass_link_tag(*sources)
    stylesheet_link_tag(*(sources.map { |css| "compiled/#{css}" }))
  end

  # Note: this depends on a "global" variable @entry being set
  def bedsheet_style
    bedsheet_attachment ||= @entry._?.view_preference._?.bedsheet_attachment
    bedsheet_attachment ||= @user._?.view_preference._?.bedsheet_attachment
    bedsheet_attachment ||= current_user._?.view_preference._?.bedsheet_attachment
    bedsheet_attachment ||= 'scroll'

    if request.path == dreamstars_path
      bedsheet_url = "/images/bedsheets/dreamstars-aurora-hi.jpg" 
    else
      # if user has ubiquity mode, use user's bedsheet no matter what
      # Not yet implemented.
      bedsheet_image ||= @entry._?.view_preference._?.image
      bedsheet_image ||= @user._?.view_preference._?.image
      bedsheet_image ||= current_user._?.view_preference._?.image

      if is_mobile?
        bedsheet_url = bedsheet_image._?.url(:bedsheet_small, :format => 'jpg')
      else
        bedsheet_url = bedsheet_image._?.url(:bedsheet, :format => 'jpg')
      end
      bedsheet_url ||= "/images/bedsheets/aurora_green-lo.jpg"
    end
    "background: url(#{bedsheet_url}) repeat #{bedsheet_attachment} 0 0"
  end
  
  def theme
    theme ||= @entry._?.view_preference._?.theme
    theme ||= @user._?.view_preference._?.theme
    theme ||= current_user._?.view_preference._?.theme
    theme ||= "light"
    theme
  end
end
