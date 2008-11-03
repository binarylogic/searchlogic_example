# Confugration
Searchlogic::Config.configure do |config|
  config.search.per_page = config.helpers.per_page_select_choices.first.last # 10
end

# Actual function for MySQL databases only
class SoundsLike < Searchlogic::Condition::Base
  class << self
    # The name of the conditions. By default its the name of the class, if you want alternate or alias conditions just add them on.
    # If you don't want to add aliases you don't even need to define this method
    def name_for_columsn(column)
      super + ["sounds", "similar_to"]
    end
  end

  # You can return an array or a string. NOT a hash, because all of these conditions
  # need to eventually get merged together. The array or string can be anything you would put in
  # the :conditions option for ActiveRecord::Base.find(). Also notice the column_sql variable. This is essentail
  # for applying modifiers and should be used in your conditions wherever you want the column.
  def to_conditions(value)
    ["#{column_sql} SOUNDS LIKE ?", value]
  end
end

Searchlogic::Conditions::Base.register_condition(SoundsLike)
