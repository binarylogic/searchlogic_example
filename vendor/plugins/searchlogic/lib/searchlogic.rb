$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "active_support"
require "active_record"
require "active_record/version"

["mysql", "postgresql", "sqlite"].each do |adapter_name|
  begin
    require "active_record/connection_adapters/#{adapter_name}_adapter"
    require "searchlogic/active_record/connection_adapters/#{adapter_name}_adapter"
  rescue Exception
  end
end

# Core Ext
require "searchlogic/core_ext/hash"

# Shared
require "searchlogic/shared/utilities"
require "searchlogic/shared/virtual_classes"

# Base classes
require "searchlogic/version"
require "searchlogic/config/helpers"
require "searchlogic/config/search"
require "searchlogic/config"

# ActiveRecord
require "searchlogic/active_record/base"
require "searchlogic/active_record/associations"

# Search
require "searchlogic/search/ordering"
require "searchlogic/search/pagination"
require "searchlogic/search/conditions"
require "searchlogic/search/searching"
require "searchlogic/search/base"
require "searchlogic/search/protection"

# Conditions
require "searchlogic/conditions/protection"
require "searchlogic/conditions/base"

# Condition
require "searchlogic/condition/base"
require "searchlogic/condition/tree"
SEARCHGASM_CONDITIONS = [:begins_with, :blank, :child_of, :descendant_of, :ends_with, :equals, :greater_than, :greater_than_or_equal_to, :inclusive_descendant_of, :like, :nil, :not_begin_with, :not_blank, :not_end_with, :not_equal, :not_have_keywords, :not_nil, :keywords, :less_than, :less_than_or_equal_to, :sibling_of]
SEARCHGASM_CONDITIONS.each { |condition| require "searchlogic/condition/#{condition}" }

# Modifiers
require "searchlogic/modifiers/base"
SEARCHGASM_MODIFIERS = [:absolute, :acos, :asin, :atan, :ceil, :char_length, :cos, :cot, :day_of_month, :day_of_week, :day_of_year, :degrees, :exp, :floor, :hex, :hour, :log, :log10, :log2, :lower, :ltrim, :md5, :microseconds, :milliseconds, :minute, :month, :octal, :radians, :round, :rtrim, :second, :sign, :sin, :square_root, :tan, :trim, :upper, :week, :year]
SEARCHGASM_MODIFIERS.each { |modifier| require "searchlogic/modifiers/#{modifier}" }

# Helpers
require "searchlogic/helpers/utilities"
require "searchlogic/helpers/form"
require "searchlogic/helpers/control_types/link"
require "searchlogic/helpers/control_types/links"
require "searchlogic/helpers/control_types/select"
require "searchlogic/helpers/control_types/remote_link"
require "searchlogic/helpers/control_types/remote_links"
require "searchlogic/helpers/control_types/remote_select"

# Lets do it!
module Searchlogic
  module Search
    class Base
      include Conditions
      include Ordering
      include Protection
      include Pagination
      include Searching
    end
  end
  
  module Conditions
    class Base
      include Protection
    end
    
    SEARCHGASM_CONDITIONS.each { |condition| Base.register_condition("Searchlogic::Condition::#{condition.to_s.camelize}".constantize) }
    SEARCHGASM_MODIFIERS.each { |modifier| Base.register_modifier("Searchlogic::Modifiers::#{modifier.to_s.camelize}".constantize) }
  end
  
  # The namespace I put all cached search classes.
  module Cache
  end
end