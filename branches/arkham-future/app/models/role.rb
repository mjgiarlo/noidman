class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  belongs_to :authorities
  belongs_to :minters
  validates_presence_of :name
end
