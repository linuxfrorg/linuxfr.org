# encoding: utf-8
module UsersHelper

  def avatar_img(user)
    return '' if user.nil?
    return '' if current_account && current_account.hide_avatar?
    options = {
      class: "avatar",
      alt: "",
      width: AvatarUploader::AVATAR_SIZE,
      height: AvatarUploader::AVATAR_SIZE
    }
    image_tag(user.avatar_url, options)
  end

  def mini_avatar_img(user)
    return '' if user.nil?
    return '' if current_account && current_account.hide_avatar?
    options = {
      class: "avatar",
      alt: "",
      width: AvatarUploader::AVATAR_SIZE / 2,
      height: AvatarUploader::AVATAR_SIZE / 2
    }
    image_tag(user.avatar_url, options)
  end

  def homesite_link(user)
    return if user.homesite.blank?
    karma = user.account.try(:karma).to_i
    return unless karma > 0
    attrs = {}
    attrs[:rel] = "nofollow" unless user.account.try(:karma).to_i > Account.default_karma
    link_to("site Web personnel", user.homesite, attrs)
  end

  def jabber_link(user)
    return unless current_account
    return if user.jabber_id.blank?
    link_to("adresse XMPP", "xmpp:" + user.jabber_id)
  end

  def mastodon_link(user)
    return if user.mastodon_url.blank?
    karma = user.account.try(:karma).to_i
    return unless karma > 0
    link_to("Mastodon", user.mastodon_url)
  end
end
