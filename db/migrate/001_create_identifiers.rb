class CreateIdentifiers < ActiveRecord::Migration
  def self.up
    create_table :identifiers do |t|
      t.column :ark, :string, :null => false
      t.column :url, :string, :null => false
      t.column :comment, :text
      t.column :metadata, :text
      t.column :authority_id, :integer, :null => false
      t.column :contract_id, :integer
      t.column :user_id, :integer, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :identifiers
  end
end
