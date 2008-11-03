module Searchlogic
  module Condition
    class EndsWith < Base
      self.join_arrays_with_or = true
      
      class << self
        def condition_names_for_column
          super + ["ew", "ends", "end"]
        end
      end
      
      def to_conditions(value)
        ["#{column_sql} LIKE ?", "%#{value}"]
      end
    end
  end
end
