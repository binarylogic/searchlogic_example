module Searchgasm #:nodoc:
  module Search #:nodoc:
    # = Searchgasm
    #
    # Please refer the README.rdoc for usage, examples, and installation.
    
    class Base
      include Searchgasm::Shared::Utilities
      include Searchgasm::Shared::Searching
      include Searchgasm::Shared::VirtualClasses
      
      # Options ActiveRecord allows when searching
      AR_FIND_OPTIONS = ::ActiveRecord::Base.valid_find_options
      
      # Options ActiveRecord allows when performing calculations
      AR_CALCULATIONS_OPTIONS = (::ActiveRecord::Base.valid_calculations_options - [:select, :limit, :offset, :order, :group])
      
      AR_OPTIONS = (AR_FIND_OPTIONS + AR_CALCULATIONS_OPTIONS).uniq
      
      # Options that ActiveRecord doesn't suppport, but Searchgasm does
      SPECIAL_FIND_OPTIONS = [:order_by, :order_as, :page, :per_page]
      
      # Valid options you can use when searching
      OPTIONS = SPECIAL_FIND_OPTIONS + AR_OPTIONS # the order is very important, these options get set in this order
      
      attr_accessor *AR_OPTIONS
      
      class << self
        # Used in the ActiveRecord methods to determine if Searchgasm should get involved or not.
        # This keeps Searchgasm out of the way unless it is needed.
        def needed?(model_class, options)
          SPECIAL_FIND_OPTIONS.each do |option|
            return true if options.symbolize_keys.keys.include?(option)
          end
                    
          Searchgasm::Conditions::Base.needed?(model_class, options[:conditions])
        end
      end
      
      def initialize(init_options = {})
        self.options = init_options
      end
      
      # Flag to determine if searchgasm is acting as a filter for the ActiveRecord search methods.
      # The purpose of this is to determine if Config.per_page should be implemented.
      def acting_as_filter=(value)
        @acting_as_filter = value
      end
      
      # See acting_as_filter=
      def acting_as_filter?
        @acting_as_filter == true
      end
      
      # Makes using searchgasm in the console less annoying and keeps the output meaningful and useful
      def inspect
        current_find_options = {}
        (AR_OPTIONS - [:conditions]).each do |option|
          value = send(option)
          next if value.nil?
          current_find_options[option] = value
        end
        conditions_value = conditions.conditions
        current_find_options[:conditions] = conditions_value unless conditions_value.blank?
        current_find_options[:scope] = scope unless scope.blank?
        "#<#{klass}Search #{current_find_options.inspect}>"
      end
      
      def joins=(value)
        @memoized_joins = nil
        @joins = value
      end
      
      def joins
        @memoized_joins ||= @joins
      end
      
      def limit=(value)
        @set_limit = true
        @limit = value.blank? || value == 0 ? nil : value.to_i
      end
      
      def limit
        @limit ||= Config.per_page if !acting_as_filter? && !@set_limit
        @limit
      end
      
      def offset=(value)
        @offset = value.blank? ? nil : value.to_i
      end

      def options=(values)
        return unless values.is_a?(Hash)
        values.symbolize_keys.fast_assert_valid_keys(OPTIONS)
        
        OPTIONS.each do |option|
          next unless values.has_key?(option)
          send("#{option}=", values[option])
        end
        
        values
      end
      
      # Sanitizes everything down into options ActiveRecord::Base.find can understand
      def sanitize(searching = true)
        find_options = {}
        
        (searching ? AR_FIND_OPTIONS : AR_CALCULATIONS_OPTIONS).each do |find_option|
          value = send(find_option)
          next if value.blank?
          find_options[find_option] = value
        end

        unless find_options[:joins].blank?
          # The following is to return uniq records since we are using joins instead of includes
          if searching
            find_options[:group] ||= "#{quote_table_name(klass.table_name)}.#{quote_column_name(klass.primary_key)}"
          else
            # If we are calculating use includes because they use joins that grab uniq records. When calculating, includes don't have the
            # performance hit that they have when searching. Plus it's cleaner.
            find_options[:include] = merge_joins(find_options[:include], find_options.delete(:joins))
          end
        end

        find_options
      end
      
      def scope
        @scope ||= {}
      end
    end
  end
end