class User < ActiveRecord::Base
  belongs_to :user_group
  has_many :orders
end
