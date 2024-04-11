# encoding: utf-8
# == Schema Information
#
# Table name: bookmarks
#
#  id          :integer          not null, primary key
#  title       :string(160)      not null
#  cached_slug :string(165)      not null
#  owner_id    :integer
#  link        :string(255)      not null
#  lang        :string(2)        not null
#  created_at  :datetime
#  updated_at  :datetime
#

# The users can post on theirs bookmarks.
# They can be used for sharing interesting,
# stuff found on other websites.
#
class Bookmark < Content
  self.table_name = "bookmarks"
  self.type = "Lien"

  belongs_to :owner, class_name: 'User'

  validates :title,     presence: { message: "Le titre est obligatoire" },
                        length: { maximum: 100, message: "Le titre est trop long" },
                        uniqueness: { message: "Un lien avec le même titre a déjà été proposé" }
  validates :link, presence: { message: "Vous ne pouvez pas poster un lien vide" },
                   http_url: { message: "Le lien n'est pas valide" },
                   length: { maximum: 255, message: "Le lien est trop long" },
                   uniqueness: { message: "Le lien a déjà été proposé" }
  validates :lang, inclusion: { in: Lang.valid_codes, allow_nil: false, message: "La langue du lien doit être définie" }

  def link=(raw)
    raw.strip!
    return write_attribute :url, nil if raw.blank?
    uri = URI.parse(raw)
    # Default to HTTP link if neither scheme nor host is found
    if uri.scheme.blank? && uri.host.blank?
      raw = "http://#{raw}"
      uri = URI.parse(raw)
    end
    write_attribute :link, uri.to_s
  # Let raw value if error when parsed, HttpUrlValidator will manage it
  rescue URI::InvalidURIError
    write_attribute :link, raw
  end

  def create_node(attrs={})
    attrs[:cc_licensed] = false
    super
  end

  def label_for_expand
    "Discuter"
  end

  def alternative_formats
    false
  end

### SEO ###

  extend FriendlyId
  friendly_id

  def should_generate_new_friendly_id?
    title_changed?
  end

### ACL ###

  def creatable_by?(account)
    account.karma > 0
  end

  def updatable_by?(account)
    account.moderator? || account.admin?
  end

  def destroyable_by?(account)
    account.moderator? || account.admin?
  end

end
