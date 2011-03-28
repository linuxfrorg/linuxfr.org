# == Schema Information
#
# Table name: tags
#
#  id             :integer(4)      not null, primary key
#  name           :string(64)      not null
#  taggings_count :integer(4)      default(0), not null
#

class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy, :inverse_of => :tag
  has_many :nodes, :through => :taggings, :uniq => true

  validates :name, :presence => true, :uniqueness => true

  scope :footer, lambda {
    select([:name]).joins(:taggings).
                    where("created_at > ?", 2.month.ago).
                    group(:tag_id).
                    order("COUNT(*) DESC").
                    limit(12)
  }

end
