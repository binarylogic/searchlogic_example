require File.dirname(__FILE__) + '/test_helper.rb'

class TestSearchBase < Test::Unit::TestCase
  def test_needed
    assert Searchgasm::Search::Base.needed?(Account, :page => 2, :conditions => {:name => "Ben"})
    assert !Searchgasm::Search::Base.needed?(Account, :conditions => {:name => "Ben"})
    assert Searchgasm::Search::Base.needed?(Account, :limit => 2, :conditions => {:name_contains => "Ben"})
    assert !Searchgasm::Search::Base.needed?(Account, :limit => 2)
    assert Searchgasm::Search::Base.needed?(Account, :per_page => 2)
  end

  def test_initialize
    assert_nothing_raised { Account.new_search }
    search = Account.new_search!(:conditions => {:name_like => "binary"}, :page => 2, :limit => 10, :readonly => true)
    assert_equal Account, search.klass
    assert_equal "binary", search.conditions.name_like
    assert_equal 2, search.page
    assert_equal 10, search.limit
    assert_equal true, search.readonly
  end
  
  def test_acting_as_filter
    search = Account.new_search
    search.acting_as_filter = true
    assert search.acting_as_filter?
    search.acting_as_filter = false
    assert !search.acting_as_filter?
  end

  def test_setting_first_level_options
    search = Account.new_search!(:include => :users, :joins => :test, :offset => 5, :limit => 20, :order => "name ASC", :select => "name", :readonly => true, :group => "name", :from => "accounts", :lock => true)
    assert_equal :users, search.include
    assert_equal :test, search.joins
    assert_equal 5, search.offset
    assert_equal 20, search.limit
    assert_equal "name ASC", search.order
    assert_equal "name", search.select
    assert_equal true, search.readonly
    assert_equal "name", search.group
    assert_equal "accounts", search.from
    assert_equal true, search.lock
    
    search = Account.new_search(:per_page => nil)
  
    search.include = :users
    assert_equal :users, search.include
  
    search.joins = "test"
    assert_equal "test", search.joins
  
    search.page = 5
    assert_equal 1, search.page
    assert_equal nil, search.offset
  
    search.limit = 20
    assert_equal search.limit, 20
    assert_equal search.per_page, 20
    assert_equal search.page, 5
    assert_equal search.offset, 80
    search.limit = nil
    assert_equal nil, search.limit
    assert_equal nil, search.per_page
    assert_equal 1, search.page
    assert_equal nil, search.offset
  
    search.offset = 50
    assert_equal 50, search.offset
    assert_equal 1, search.page
    search.limit = 50
    assert_equal 2, search.page
    search.offset = nil
    assert_equal nil, search.offset
    assert_equal 1, search.page
  
    search.per_page = 2
    assert_equal 2, search.per_page
    assert_equal 2, search.limit
    search.offset = 50
    assert_equal 26, search.page
    assert_equal 50, search.offset
  
    search.order = "name ASC"
    assert_equal search.order, "name ASC"
  
    search.select = "name"
    assert_equal search.select, "name"
  
    search.readonly = true
    assert_equal search.readonly, true
  
    search.group = "name"
    assert_equal search.group, "name"
  
    search.from = "accounts"
    assert_equal search.from, "accounts"
  
    search.lock = true
    assert_equal search.lock, true
  end

  def test_auto_joins
    search = Account.new_search
    assert_equal nil, search.auto_joins
    search.conditions.name_contains = "Binary"
    assert_equal nil, search.auto_joins
    search.conditions.users.first_name_contains = "Ben"
    assert_equal(:users, search.auto_joins)
    search.conditions.users.orders.id_gt = 2
    assert_equal({:users => :orders}, search.auto_joins)
    search.conditions.users.reset_orders!
    assert_equal(:users, search.auto_joins)
    search.conditions.users.orders.id_gt = 2
    search.conditions.reset_users!
    assert_equal nil, search.auto_joins
  end

  def test_limit
    search = Account.new_search
    search.limit = 10
    assert_equal 10, search.limit
    search.page = 2
    assert_equal 10, search.offset
    search.limit = 25
    assert_equal 25, search.offset
    assert_equal 2, search.page
    search.page = 5
    assert_equal 5, search.page
    assert_equal 25, search.limit
    search.limit = 3
    assert_equal 12, search.offset
  end

  def test_options
  end

  def test_sanitize
    search = Account.new_search
    search.per_page = 2
    search.conditions.name_like = "Binary"
    search.conditions.users.id_greater_than = 2
    search.page = 3
    search.readonly = true
    assert_equal({:joins => :users, :group => "\"accounts\".\"id\"", :offset => 4, :readonly => true, :conditions => ["(\"accounts\".\"name\" LIKE ?) AND (\"users\".\"id\" > ?)", "%Binary%", 2], :limit => 2 }, search.sanitize)
  end

  def test_scope
    search = Account.new_search!
    search.conditions = "some sql"
    conditions = search.conditions
    assert_equal "some sql", search.conditions.conditions
    search.conditions = nil
    assert_equal nil, search.conditions.conditions
    search.conditions = "some sql"
    assert_equal "some sql", search.conditions.conditions
    search.conditions = "some sql"
    assert_equal "some sql", search.conditions.conditions
  end

  def test_searching
    search = Account.new_search
    search.conditions.name_like = "Binary"
    assert_equal [Account.find(1), Account.find(3)], search.all
    assert_equal [Account.find(1), Account.find(3)], search.find(:all)
    assert_equal Account.find(1), search.first
    assert_equal Account.find(1), search.find(:first)
  
    search.per_page = 20
    search.page = 2
  
    assert_equal [], search.all
    assert_equal [], search.find(:all)
    assert_equal nil, search.first
    assert_equal nil, search.find(:first)
      
    search.per_page = 0
    search.page = nil
    search.conditions.users.first_name_contains = "Ben"
    search.conditions.users.orders.description_keywords = "products, &*ap#ple $%^&*"
    assert_equal [Account.find(1)], search.all
    assert_equal [Account.find(1)], search.find(:all)
    assert_equal Account.find(1), search.first
    assert_equal Account.find(1), search.find(:first)
    
    search = Account.new_search
    search.select = "id, name"
    assert_equal Account.all, search.all
  end

  def test_calculations
    search = Account.new_search
    search.conditions.name_like = "Binary"
    assert_equal 2, search.average('id')
    assert_equal 2, search.calculate(:avg, 'id')
    assert_equal 3, search.calculate(:max, 'id')
    assert_equal 2, search.count
    assert_equal 3, search.maximum('id')
    assert_equal 1, search.minimum('id')
    assert_equal 4, search.sum('id')
    
    search.readonly = true
    assert_equal 4, search.sum('id')
  end
  
  def test_method_creation_in_scope
    # test ot make sure methods are not created across the board for all models
  end
  
=begin
  # AR desont handle this problem either
  def test_specifying_includes
    search = Account.new_search
    search.include = :users
    search.conditions.users.first_name_like = "Ben"
    assert_nothing_raised { search.all }
  end
=end
  
  def test_inspect
    search = Account.new_search
    assert_nothing_raised { search.inspect }
  end
end