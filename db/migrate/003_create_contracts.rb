class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.column :statement, :text, :null => false
      t.column :label, :string, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :contracts
  end
end
