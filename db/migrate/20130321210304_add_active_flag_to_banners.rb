class AddActiveFlagToBanners < ActiveRecord::Migration
  def change
    add_column :banners, :active, :boolean, :default => true
  end
end
