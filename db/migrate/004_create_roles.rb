class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string
      t.column :label, :text
      t.column :authority_id, :integer
      t.column :minter_id, :integer
    end
  end

  def self.down
    drop_table :roles
  end
end
