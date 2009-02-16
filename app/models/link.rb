# == Schema Information
# Schema version: 20090120005239
#
# Table name: links
#
#  id         :integer(4)      not null, primary key
#  news_id    :integer(4)
#  title      :string(255)
#  url        :string(255)
#  lang       :string(255)
#  nb_clicks  :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

# The news can have some important links.
# We follow the number of clicks on each of these links.
#
class Link < ActiveRecord::Base
  belongs_to :news

  validates_presence_of :title, :message => 'Un lien doit obligatoirement avoir un titre'
  validates_presence_of :url,   :message => 'Un lien doit obligatoirement avoir une URL'

  def url=(url)
    url = "http://#{url}" if !url.blank? && !url.starts_with?('http://')
    write_attribute :url, url
  end
end
