class CreateAuthorities < ActiveRecord::Migration
  def self.up
    create_table :authorities do |t|
      t.column :number, :integer
      t.column :label, :string
    end
  end

  def self.down
    drop_table :authorities
  end
end
