class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.column :statement, :string
      t.column :label, :string
    end
  end

  def self.down
    drop_table :contracts
  end
end
