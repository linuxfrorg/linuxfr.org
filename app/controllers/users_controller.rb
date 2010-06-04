class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @user
    @order    = params[:order] || 'created_at'
    @nodes    = Node.public_listing(Diary, @order).where("nodes.user_id" => @user.id).paginate(:page => params[:page], :per_page => 10)
    @contents = Node.visible.by_date.limit(20).where("nodes.user_id" => @user.id)
    respond_to do |wants|
      wants.html
      wants.atom { render 'diaries/index' }
    end
  end

end
