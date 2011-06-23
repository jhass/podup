class AddAcceptedToPods < ActiveRecord::Migration
  def self.up
    add_column :pods, :accepted, :boolean, :default => false
  end

  def self.down
    remove_column :pods, :accepted
  end
end
