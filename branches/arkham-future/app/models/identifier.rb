class Identifier < ActiveRecord::Base
  belongs_to :users
  belongs_to :minters
  belongs_to :contracts
  validates_presence_of :ark, :url, :minter_id, :user_id
  validates_uniqueness_of :ark, :url, :scope => [:minter_id]
end
