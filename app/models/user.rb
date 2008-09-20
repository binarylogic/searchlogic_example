class User < ActiveRecord::Base
  belongs_to :user_group
  has_one :cool_order, :class_name => "Order", :conditions => {:total => 100}
  has_many :orders
end
