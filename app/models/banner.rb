# == Schema Information
#
# Table name: banners
#
#  id      :integer(4)      not null, primary key
#  title   :string(255)
#  content :text
#

class Banner < ActiveRecord::Base
  validates_presence_of :content, :message => "La bannière ne peut être vide !"

  def self.random
    banner = order("RAND()").first
    banner && banner.content
  end
end
