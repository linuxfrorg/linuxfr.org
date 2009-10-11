module Authlogic::Session::Cookies::InstanceMethods

  def save_cookie
    cookie = {
      :value => "#{record.persistence_token}::#{record.send(record.class.primary_key)}",
      :expires => remember_me_until,
      :domain => controller.cookie_domain,
      :httponly => true
    }
    if controller.request.ssl?
      cookie[:secure] = true
      controller.cookies["https"] = "1"
    end
    controller.cookies[cookie_key] = cookie
  end

  def destroy_cookie
    controller.cookies.delete cookie_key, :domain => controller.cookie_domain
    controller.cookies.delete "https"
  end

end
