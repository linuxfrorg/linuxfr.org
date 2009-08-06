# == Schema Information
#
# Table name: pages
#
#  id         :integer(4)      not null, primary key
#  slug       :string(255)
#  title      :string(255)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

class Page < ActiveRecord::Base
  validates_presence_of :slug,  :message => "Le slug est obligatoire"
  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Le corps est obligatoire"

  def to_param
    slug
  end
end
