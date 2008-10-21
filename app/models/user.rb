class User < ActiveRecord::Base
  belongs_to :user_group
  has_many :orders, :dependent => :destroy
  
  def name(middle_name = "")
    "#{first_name} #{middle_name} #{last_name}"
  end
end
