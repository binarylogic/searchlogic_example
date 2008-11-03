module Searchlogic
  module ActiveRecord
    module ConnectionAdapters
      module SQLiteAdapter
        # Date functions
        def microseconds_sql(column_name)
          "((strftime('%f', #{column_name}) % 1) * 1000000)"
        end
        
        def milliseconds_sql(column_name)
          "((strftime('%f', #{column_name}) % 1) * 1000)"
        end
        
        def second_sql(column_name)
          "strftime('%S', #{column_name})"
        end
        
        def minute_sql(column_name)
          "strftime('%M', #{column_name})"
        end
        
        def hour_sql(column_name)
          "strftime('%H', #{column_name})"
        end
        
        def day_of_week_sql(column_name)
          "strftime('%w', #{column_name})"
        end
        
        def day_of_month_sql(column_name)
          "strftime('%d', #{column_name})"
        end
        
        def day_of_year_sql(column_name)
          "strftime('%j', #{column_name})"
        end
        
        def week_sql(column_name)
          "strftime('%W', #{column_name})"
        end
        
        def month_sql(column_name)
          "strftime('%m', #{column_name})"
        end
        
        def year_sql(column_name)
          "strftime('%Y', #{column_name})"
        end
        
        # String functions
        def lower_sql(column_name)
          "lower(#{column_name})"
        end
        
        def ltrim_sql(column_name)
          "ltrim(#{column_name})"
        end
        
        def rtrim_sql(column_name)
          "rtrim(#{column_name})"
        end
        
        def trim_sql(column_name)
          "trim(#{column_name})"
        end
        
        def upper_sql(column_name)
          "upper(#{column_name})"
        end
      end
    end
  end
end

::ActiveRecord::ConnectionAdapters::SQLiteAdapter.send(:include, Searchlogic::ActiveRecord::ConnectionAdapters::SQLiteAdapter)