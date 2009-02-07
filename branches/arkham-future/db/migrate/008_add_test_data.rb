class AddTestData < ActiveRecord::Migration
  def self.up
    @role = Role.create :name => 'ARKHAM_ADMIN', :label => 'Site-level administrator'
    @user = User.create :name => 'Michael J. Giarlo', :password =>  '', :email => 'mgiarlo@princeton.edu'
    @contract = Contract.create :statement => 'yada yada yada', :label =>  'Persistence in perpetuity'
    @authority = Authority.create :number => 88435, :label =>  'Princeton University Library'
    @minter = Minter.create :label => 'Sequential Test', :random => false, :authority_id => @authority, :prefix => 'test'
    @identifier = Identifier.create :ark => @minter.mint!,
      :url =>  'http://diglib.princeton.edu/',
      :authority_id => @authority,    
      :user_id => @user
  end

  def self.down
  end
end
