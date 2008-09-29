class NonAjax::UsersController < ApplicationController
  def index
    @search = User.new_search(params[:search])
    @search.order_by ||= :first_name
    @users, @users_count = @search.all, @search.count
  end
end