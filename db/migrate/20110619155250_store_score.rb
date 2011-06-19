class StoreScore < ActiveRecord::Migration
  def self.up
    add_column :pods, :score, :float
  end

  def self.down
    remove_column :pods, :score
  end
end
