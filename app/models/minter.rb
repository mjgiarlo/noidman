class Minter < ActiveRecord::Base
  has_many :identifiers
  belongs_to :authorities
  validates_presence_of :random
  def mint
    ArkUtils.mint!( self )
  end
end
