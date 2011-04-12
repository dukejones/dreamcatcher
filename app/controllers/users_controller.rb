class UsersController < ApplicationController
  def update
    @user = current_user # User.find params[:id]
    # raise "access denied" unless @user == current_user

    if @user.link && params[:user][:link_attributes]._?[:url].blank?
      @user.link.destroy
      @user.link = nil
      params[:user].delete(:link_attributes)
    end
    
    if @user.update_attributes(params[:user])
      respond_to do |format|
        format.html { render :text => "user updated" }
        format.json { render :json => {type: 'ok', message: 'user updated'}}
      end
    else
      respond_to do |format|
        format.html { render :text => "user error" }
        format.json { render :json => {type: 'error', errors: @user.errors}}.to_json
      end
    end
  end

  def create_location
    new_where = Where.create(params[:new_location])
    current_user.wheres << new_where
    render :partial => 'layouts/location', :object => new_where
  end
  
  def friends
    @user = User.find_by_username(params[:username])

    redirect_to(root_path, {alert: "User #{params[:username]} does not exist."}) and return unless @user
      
    
    @mode = params[:mode] 
    @friends = case @mode
      when 'friends'   then @user.friends
      when 'following' then @user.following
      when 'followers' then @user.followers
    end
  end
  
  def follow
    redirect_to :root and return unless current_user
    
    user = User.find_by_username(params[:username])

    case params[:verb]
      when 'follow' then current_user.following << user unless current_user.following?(user)
      when 'unfollow' then current_user.following.delete user if current_user.following?(user)
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => {type: 'ok', message: 'success'} }
    end
  end
  
  def confirm
    #redirect_to login_path, :alert => 'please log in, then try confirming again' and return unless current_user
    user = User.find params[:id]
    if params[:confirmation] == user.confirmation_code
      flash.notice = "email address has been confirmed"
    else
      flash.alert = "confirmation code did not match logged-in user"
    end
  end
  
  def search
    search_string = "%#{params[:search_string]}%"
    @users = User.where("username LIKE :search OR email LIKE :search OR name LIKE :search", {search: search_string}).
      limit(50).order('starlight DESC')
  end
  
  def wrong_email
    # here we will disable the user / delete it / etc
    raise "Not yet implemented."
  end
  
  # XHR only
  def bedsheet
    @user = current_user
    @user.view_preference.update_attribute(:image, Image.find(params[:bedsheet_id]))
    render :json => "user bedsheet updated"
  rescue => e
    render :json => e.message, :status => :unprocessable_entity
  end
  
  # XHR only
  def set_view_preferences
    @user = current_user
    @user.view_preference.update_attribute(:image, Image.find(params[:bedsheet_id])) unless params[:bedsheet_id].nil?
    @user.view_preference.update_attribute(:bedsheet_attachment, params[:scrolling]) unless params[:scrolling].nil?
    @user.view_preference.update_attribute(:theme, params[:theme]) unless params[:theme].nil?
    render :json => "user view preferences updated"
  rescue => e
    render :json => e.message, :status => :unprocessable_entity
  end
  
  # XHR only.
  def avatar
    @image = Image.new({
      section: 'Avatar',
      incoming_filename: params[:qqfile],
      uploaded_by: current_user
    })
    @image.save!
    @image.write(request.body.read)

    current_user.image = @image
    current_user.save
    
    render :json => { :avatar_path => @image.url('avatar_main'), :avatar_thumb_path => @image.url(:avatar, :size => 32), :avatar_image => @image }
  end
end
