class AddStuffToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :name, :string
    add_column :locations, :flag, :string
    add_index :locations, :code, :unique => true
  end

  def self.down
    remove_column :locations, :flag
    remove_column :locations, :name
    remove_index :locations, :code
  end
end
