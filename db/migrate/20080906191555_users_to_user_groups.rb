class UsersToUserGroups < ActiveRecord::Migration
  def self.up
    add_column :users, :user_group_id, :integer
  end

  def self.down
    remove_column :users, :user_group_id
  end
end
