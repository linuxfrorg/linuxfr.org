# encoding: UTF-8
# == Schema Information
#
# Table name: banners
#
#  id      :integer          not null, primary key
#  title   :string(255)
#  content :text(16777215)
#  active  :boolean          default(TRUE)
#
class Banner < ApplicationRecord
  scope :active, -> { where(active: true) }

  validates :title, presence: { message: "Le titre ne peut être vide" },
                    length: { maximum: 255, message: "Le titre est trop long" }

  validates :content, presence: { message: "La bannière ne peut être vide" }

  def self.random
    nb = $redis.llen("banners")
    return nil if nb == 0
    id = $redis.lindex("banners", rand(nb))
    Banner.find(id).try(:content)
  end

  after_save :index_banners
  after_destroy :index_banners
  def index_banners
    $redis.del("banners")
    Banner.active.each do |b|
      $redis.rpush("banners", b.id)
    end
  end

  def content
    read_attribute(:content).to_s.html_safe
  end
end
