# encoding: UTF-8
# == Schema Information
#
# Table name: forums
#
#  id          :integer          not null, primary key
#  state       :string(10)       default("active"), not null
#  title       :string(32)       not null
#  cached_slug :string(32)
#  position    :integer
#  created_at  :datetime
#  updated_at  :datetime
#

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

  extend FriendlyId
  friendly_id

### Workflow ###

  state_machine :state, :initial => :active do
    event :reopen  do transition :archived => :active end
    event :archive do transition :active => :archived end
  end

### Interest ###

  def self.interest_coefficient
    1
  end

### Presentation ###

  def first_level
    title.split('.').first
  end

  def second_level
    title.split('.').second
  end

end
