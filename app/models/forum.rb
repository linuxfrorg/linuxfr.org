# == Schema Information
#
# Table name: forums
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("active"), not null
#  title       :string(255)
#  cached_slug :string(255)
#  position    :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

# The forums is the place where the users ask questions and answer them.
# It'as all about helping each others.
#
class Forum < ActiveRecord::Base
  acts_as_list

  has_many :posts, :inverse_of => :forum

  scope :sorted, order("position ASC")
  scope :active, where(:state => "active")

  validates :title, :presence   => { :message => "Le titre est obligatoire" },
                    :uniqueness => { :message => "Ce titre est déjà utilisé" }

  has_friendly_id :title, :use_slug => true

### Interest ###

  def self.interest_coefficient
    1
  end

end
