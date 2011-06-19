class AddStuffToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :name, :string
    add_column :users, :website, :string
    add_column :users, :public_email, :string
  end

  def self.down
    remove_column :users, :name
    remove_column :users, :website
    remove_column :users, :public_email
  end
end
