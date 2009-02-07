class CreateAuthorities < ActiveRecord::Migration
  def self.up
    create_table :authorities do |t|
      t.column :number, :integer, :null => false
      t.column :label, :string, :null => false
      t.column :host, :string, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :authorities
  end
end
