module UsersHelper

  def avatar_url(user)
    return '' if user.nil?
    url = user.avatar.url(:thumbnail)
    options = { :class => "avatar", :alt => "Avatar de #{user.name}", :width => User::AVATAR_SIZE, :heigth => User::AVATAR_SIZE }
    if url == User::DEFAULT_AVATAR_URL
      options['data-gravatar'] = user.gravatar_hash
    end
    url.sub(/^http:/, 'https:') if request.ssl?
    image_tag(url, options)
  end

end
