# encoding: UTF-8
#
# == Schema Information
#
# Table name: sections
#
#  id                 :integer(4)      not null, primary key
#  state              :string(255)     default("published"), not null
#  title              :string(255)
#  cached_slug        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

# The news are classified in several sections.
#
class Section < ActiveRecord::Base
  has_many :news, :inverse_of => :section

  scope :published, where(:state => "published").order("title")

  validates :title, :presence   => { :message => "Le titre est obligatoire" },
                    :uniqueness => { :message => "Ce titre est déjà utilisé" }

### SEO ###

  has_friendly_id :title, :use_slug => true, :reserved_words => %w(index nouveau)

### Image ###

  def image
    "/images/sections/#{self.id}.png"
  end

### Workflow ###

  state_machine :state, :initial => :published do
    event :reopen  do transition :archived => :published end
    event :archive do transition :published => :archived end
  end

end
