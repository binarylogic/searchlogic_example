# Confugration
Searchgasm::Config.configure do |config|
  config.per_page = config.per_page_choices.first # 10
end

# Actual function for MySQL databases only
class SoundsLikeCondition < Searchgasm::Condition::Base
  class << self
    # I pass you the column, you tell me what you want the method to be called.
    # If you don't want to add this condition for that column, return nil
    # It defaults to "#{column.name}_sounds_like". So if thats what you want you don't even need to do this.
    def name_for_column(column)
      return unless column.type == :string
      super
    end

    # Only do this if you want aliases for your condition
    def aliases_for_column(column)
      ["#{column.name}_sounds", "#{column.name}_similar_to"]
    end
  end

  # You can return an array or a string. NOT a hash, because all of these conditions
  # need to eventually get merged together. The array or string can be anything you would put in
  # the :conditions option for ActiveRecord::Base.find()
  def to_conditions(value)
    ["#{quoted_table_name}.#{quoted_column_name} SOUNDS LIKE ?", value]
  end
end

Searchgasm::Conditions::Base.register_condition(SoundsLikeCondition)
