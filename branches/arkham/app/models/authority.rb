class Authority < ActiveRecord::Base
  has_many :identifiers
  validates_presence_of :number, :label
  validates_uniqueness_of :number, :label
  validates_numericality_of :number
  # XXX an identifier must be minted and returned prior to the ActiveRecord::Base#create method invocation
  def mint
    ArkUtils.mint( :authority => self, :template => 'eeddeeddk' )
  end
end
