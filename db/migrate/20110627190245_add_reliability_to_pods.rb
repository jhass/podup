class AddReliabilityToPods < ActiveRecord::Migration
  def self.up
    add_column :pods, :reliability, :float
  end

  def self.down
    remove_column :pods, :reliability
  end
end
