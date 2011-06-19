class CreatePods < ActiveRecord::Migration
  def self.up
    create_table :pods do |t|
      t.string :name
      t.integer :owner_id
      t.integer :location_id
      t.string :url
      t.string :version
      t.datetime :updated
      t.timestamps
    end
  end

  def self.down
    drop_table :pods
  end
end
