class AddTestData < ActiveRecord::Migration
  def self.up
    contract = Contract.create :statement => 'yada yada yada', 
      :label =>  'Ridiculous statement'
    authority = Authority.create :number => 88435, 
      :label =>  'Princeton University Library', 
      :host => 'arks.princeton.edu'
    user = User.create :name => 'Michael J. Giarlo', 
      :password =>  'test', 
      :email => 'mgiarlo@princeton.edu',
      :admin => true
    identifier = Identifier.create :ark => authority.mint,
      :url =>  'http://diglib.princeton.edu/',
      :comment => 'This is a comment field.  It is searchable.',
      :authority_id => authority.id,
      :user_id => user.id,
      :contract_id => contract.id
  end

  def self.down
    # find and delete test data
    [Contract.find_by_statement( 'yada yada yada' ), 
     Authority.find_by_number( 88435 ), 
     User.find_by_email( 'mgiarlo@princeton.edu' ), 
     Identifier.find_by_url( 'http://diglib.princeton.edu/' )].each do |object| 
      object.destroy unless object.nil? 
    end
  end
end
