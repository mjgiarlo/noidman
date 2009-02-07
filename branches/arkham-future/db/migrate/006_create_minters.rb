class CreateMinters < ActiveRecord::Migration
  def self.up
    create_table :minters do |t|
      t.column :label, :string
      t.column :random, :boolean
      t.column :prefix, :string
      t.column :authority_id, :integer
    end
  end

  def self.down
    drop_table :minters
  end
end
