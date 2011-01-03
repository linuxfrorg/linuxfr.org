module UsersHelper

  def avatar_url(user)
    return '' if user.nil?
    image_tag(user.avatar_url(:thumbnail, request.ssl?), :class => 'avatar', :alt => "Avatar de #{user.name}")
  end

end
