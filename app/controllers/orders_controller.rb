class OrdersController < ApplicationController
  def index
    # Please see users_controller.rb for comments and information on this code.
    @search = Order.new_search(params[:search])
    @orders, @orders_count = @search.all, @search.count
  end
end