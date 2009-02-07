class CreateIndexes < ActiveRecord::Migration
  def self.up
    add_index :identifiers, :ark
    add_index :identifiers, :url
    add_index :identifiers, :comment
    add_index :users, :name
    add_index :roles, :name
    add_index :contracts, :statement
    add_index :authorities, :number
  end

  def self.down
    remove_index :identifiers, :ark
    remove_index :identifiers, :url
    remove_index :identifiers, :comment
    remove_index :users, :name
    remove_index :roles, :name
    remove_index :contracts, :statement
    remove_index :authorities, :number
  end
end