class CreateIndexes < ActiveRecord::Migration
  def self.up
    add_index :identifiers, :ark
    add_index :identifiers, :url
    add_index :users, :name
    add_index :contracts, :label
    add_index :authorities, :label
    add_index :authorities, :number
  end

  def self.down
    remove_index :identifiers, :ark
    remove_index :identifiers, :url
    remove_index :users, :name
    remove_index :contracts, :label
    remove_index :authorities, :number
    remove_index :authorities, :label
  end 
end
