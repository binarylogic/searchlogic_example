class OrdersController < ApplicationController
  def index
    # This creates a new search object to search for users. It's safe to pass params into here because
    # new_search and new_conditions are protected, meaning the structure of the params hash is run through
    # checks to ensure there is no SQL injection or anything invalid. This ultimately allows you to create a controllers action
    # that searches, orders, and paginates in 2 lines.
    @search = User.new_search(params[:search])
    
    # .all takes pagination into account. .count tells you how many records will be returned disregarding the limit and offset options.
    @users, @users_count = @search.all, @search.count
  end
end