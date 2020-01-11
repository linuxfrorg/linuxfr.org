class Api::V1::DiaryController < Api::V1::ApiController
  before_action -> { doorkeeper_authorize! :diary }
  after_action :expire_cache, only: [:create]

  def create
    diary = current_resource_owner.user.diaries.build
    diary.attributes = diary_params
    diary.cc_licensed = true
    if diary.creatable_by?(current_resource_owner)
      diary.save
      render json: diary
    else
      render json: { error: "You don’t have enough karma to post a diary" }
    end
  end

protected

  def diary_params
    params.permit(:title, :wiki_body)
  end

  def expire_cache
    expire_page controller: '/diaries', action: :index, format: :atom
  end
end
