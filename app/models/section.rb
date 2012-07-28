# encoding: UTF-8
# == Schema Information
#
# Table name: sections
#
#  id          :integer          not null, primary key
#  state       :string(10)       default("published"), not null
#  title       :string(32)       not null
#  cached_slug :string(32)
#  created_at  :datetime
#  updated_at  :datetime
#

#
# The news are classified in several sections.
#
class Section < ActiveRecord::Base
  has_many :news, :inverse_of => :section

  scope :published, where(:state => "published").order("title")

  validates :title, :presence   => { :message => "Le titre est obligatoire" },
                    :uniqueness => { :message => "Ce titre est déjà utilisé" }

### SEO ###

  extend FriendlyId
  friendly_id

### Image ###

  def image
    "/images/sections/#{self.id}.png"
  end

### Workflow ###

  state_machine :state, :initial => :published do
    event :reopen  do transition :archived => :published end
    event :archive do transition :published => :archived end
  end

  def self.default
    where(:title => "LinuxFr.org").first
  end

end
