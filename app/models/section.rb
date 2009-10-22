# == Schema Information
#
# Table name: sections
#
#  id                 :integer(4)      not null, primary key
#  state              :string(255)     default("published"), not null
#  title              :string(255)
#  cache_slug         :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer(4)
#  image_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

# The news are classified in several sections.
#
class Section < ActiveRecord::Base
  has_many :news

  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_uniqueness_of :title, :message => "Ce titre est déjà utilisé"

### SEO ###

  has_friendly_id :title

### Image ###

  has_attached_file :image, :path => ':rails_root/public/sections/:id.:extension',
                            :url  => '/sections/:id.:extension'
  validates_attachment_presence :image, :message => "L'image est obligatoire"

### Workflow ###

  include AASM
  aasm_column :state
  aasm_initial_state :published

  aasm_state :published
  aasm_state :archived

  aasm_event :reopen do transitions :from => [:archived], :to => :published end
  aasm_event :delete do transitions :from => [:published], :to => :archived end

end
