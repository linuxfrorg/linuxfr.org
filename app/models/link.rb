# == Schema Information
#
# Table name: links
#
#  id         :integer(4)      not null, primary key
#  news_id    :integer(4)
#  title      :string(255)
#  url        :string(255)
#  lang       :string(255)
#  nb_clicks  :integer(4)      default(0)
#  created_at :datetime
#  updated_at :datetime
#

# The news can have some important links.
# We follow the number of clicks on each of these links.
#
class Link < ActiveRecord::Base
  belongs_to :news

  attr_accessible :title, :url, :lang

  validates_presence_of :title, :message => 'Un lien doit obligatoirement avoir un titre'
  validates_url_format_of :url, :message => "n'est pas une URL valide"

  def url=(url)
    url = "http://#{url}" if url.present? && url.not.starts_with?('http')
    write_attribute :url, url
  end

  def hit
    self.class.increment_counter(:nb_clicks, self.id)
  end
end
