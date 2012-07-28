# encoding: utf-8
# == Schema Information
#
# Table name: pages
#
#  id         :integer          not null, primary key
#  slug       :string(255)
#  title      :string(255)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

class Page < ActiveRecord::Base
  validates :slug,  :presence => { :message => "Le slug est obligatoire" }
  validates :title, :presence => { :message => "Le titre est obligatoire" }
  validates :body,  :presence => { :message => "Le corps est obligatoire" }

### SEO ###

  before_validation :parameterize_slug
  def parameterize_slug
    self.slug = slug.parameterize
  end

  def to_param
    slug
  end

### Search ####

  class << self; attr_accessor :type; end
  self.type = "À propos de LinuxFr.org"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id,         :index    => :not_analyzed
    indexes :created_at, :type => 'date', :include_in_all => false
    indexes :title,      :analyzer => 'french', :boost => 50
    indexes :body,       :analyzer => 'french', :boost => 5
  end

  # See see https://github.com/karmi/tire/issues/48
  def self.paginate(options = {})
    page(options[:page]).per(options[:per_page])
  end

### Body ###

  def truncated_body
    LFTruncator.
      truncate(body, 80).
      sub("[...](suite)", " <a href=\"/#{slug}\">(...)</a>").
      html_safe
  end

end
