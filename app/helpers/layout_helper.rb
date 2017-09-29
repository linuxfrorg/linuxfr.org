# encoding: utf-8
module LayoutHelper

  def body_attr
    classes = []
    classes << 'logged' if current_account
    classes << current_account.role if current_account
    classes << 'no-layout' if controller.class < DeviseController
    { class: classes.join(' '), id: "#{controller.controller_name}-#{controller.action_name}" }
  end

end
