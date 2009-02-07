class User < ActiveRecord::Base
  has_many :identifiers
  validates_presence_of :name, :password, :email
end
