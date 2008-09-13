namespace :db do
  desc "Erase and fill the database with test data"
  task :populate => :environment do
    require 'populator'
    require 'faker'
    
    [UserGroup, User, Order].each(&:delete_all)
    
    # Generates 8 user groups with 0 to 150 users. 
    # Each user has 0 to 7 orders..
    UserGroup.populate 8 do |user_group|
      user_group.name   = Populator.words(1..2).titleize
      user_group.active = [true, false]
      User.populate 0..150 do |user|
        user.user_group_id  = user_group.id 
        user.first_name     = Faker::Name.first_name
        user.last_name      = Faker::Name.last_name
        user.email          = "#{user.first_name.downcase}.#{user.last_name.downcase}@#{Faker::Internet.domain_name}"
        user.born_on        = 42.years.ago..18.years.ago
        user.created_at     = 2.years.ago..Time.now
        Order.populate 0..7 do |order|
          order.user_id     = user.id
          order.total       = [ 29.95, 4.99, 795.00, 31.70, 1.99 ]
          order.description = Populator.sentences(2..6)
          order.created_at  = user.created_at..Time.now
        end
      end
    end
  end
end