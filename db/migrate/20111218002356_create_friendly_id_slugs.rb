class CreateFriendlyIdSlugs < ActiveRecord::Migration

  def change
    rename_table :slugs, :friendly_id_slugs
    change_table :friendly_id_slugs do |t|
      t.remove_index :name => :index_slugs_on_name_and_more
      t.rename :name, :slug
      t.remove :scope
      t.remove :sequence
    end
    add_index :friendly_id_slugs, [:slug, :sluggable_type], :unique => true
    add_index :friendly_id_slugs, :sluggable_type
  end

end
