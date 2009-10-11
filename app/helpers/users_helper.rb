module UsersHelper

  def avatar_url(user)
    image_tag(user.avatar_url(:thumbnail, request.ssl?), :class => 'avatar', :alt => "Avatar de #{user.name}")
  end

end
