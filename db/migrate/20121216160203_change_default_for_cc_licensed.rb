class ChangeDefaultForCcLicensed < ActiveRecord::Migration
  def change
    change_table :nodes do |t|
      t.change_default :cc_licensed, true
    end
  end
end
