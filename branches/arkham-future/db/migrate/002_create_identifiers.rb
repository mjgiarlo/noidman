class CreateIdentifiers < ActiveRecord::Migration
  def self.up
    create_table :identifiers do |t|
      t.column :ark, :string
      t.column :url, :string
      t.column :comment, :string
      t.column :metadata, :text
      t.column :minter_id, :integer
      t.column :contract_id, :integer
      t.column :user_id, :integer
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end
  end

  def self.down
    drop_table :identifiers
  end
end
