module Searchgasm
  module Helpers
    # = Form Helper
    #
    # Enables you to use form_for and fields_for just like you do with an ActiveRecord object.
    #
    # === Examples
    #
    # Let's assume @search is searching Address
    #
    #   form_for(@search) # is equivalent to form_for(:search, @search, :url => addresses_path)
    #   form_for([@current_user, @search]) # is equivalent to form_for(:search, @search, :url => user_addresses_path(@current_user))
    #   form_for([:admin, @search]) # is equivalent to form_for(:search, @search, :url => admin_addresses_path)
    #   form_for(:search, @search, :url => whatever_path)
    #
    # The goal was to mimic ActiveRecord. You can also pass a Searchgasm::Conditions::Base object as well and it will function the same way.
    #
    # === Automatic hidden fields generation
    #
    # If you pass a Searchgasm::Search::Base object it automatically adds the :order_by, :order_as, and :per_page hidden fields. This is done so that when someone
    # creates a new search, their options are remembered. It keeps the search consisten and is much more user friendly. If you want to override this you can pass the
    # following options or you can set this up in your configuration, see Searchgasm::Config for more details.
    #
    # Lastly some light javascript is added to the "onsubmit" action. You will notice the order_by, per_page, and page helpers also add in a single hidden tag in the page. The form
    # finds these elements, gets their values and updates its hidden fields so that the correct values will be submitted during the search. The end result is having the "ordering" and "per page" options remembered.
    #
    # === Options
    #
    # * <tt>:hidden_fields</tt> --- Array, a list of hidden fields to include. Defaults to [:order_by, :order_as, :per_page]. Pass false, nil, or a blank array to not include any.
    module Form
      module Shared # :nodoc:
        private
          def searchgasm_object?(object)
            object.is_a?(Search::Base) || object.is_a?(Conditions::Base)
          end
        
          def find_searchgasm_object(args)
            search_object = nil
            
            case args.first
            when String, Symbol
              begin
                search_object = searchgasm_object?(args[1]) ? args[1] : instance_variable_get("@#{args.first}")
              rescue Exception
              end
            when Array
              search_object = args.first.last
            else
              search_object = args.first
            end
          
            searchgasm_object?(search_object) ? search_object : nil
          end
          
          def extract_searchgasm_options!(args)
            options = args.extract_options!
            searchgasm_options = {}
            [:hidden_fields].each { |option| searchgasm_options[option] = options.has_key?(option) ? options.delete(option) : Config.send(option) }
            searchgasm_options[:hidden_fields] = [searchgasm_options[:hidden_fields]].flatten.compact
            args << options
            searchgasm_options
          end
        
          def searchgasm_args(args, search_object, search_options, for_helper = nil)
            args = args.dup
            first = args.shift
          
            # Rearrange args with name first, search_obj second
            case first
            when String, Symbol
              args.unshift(search_object).unshift(first)
            else
              name = search_object.is_a?(Conditions::Base) ? (search_object.relationship_name || :conditions) : :search
              args.unshift(search_object).unshift(name)
            end
            
            # Now that we are consistent, get the name
            name = args.first
            
            # Add in some form magic to keep searching consisten and user friendly
            if for_helper != :fields_for
              options = args.extract_options!
              
              # Set some defaults
              options[:html] ||= {}
              options[:html][:method] ||= :get
              options[:method] ||= options[:html][:method] if for_helper == :remote_form_for
              #options[:html][:id] ||= searchgasm_form_id(search_object)
              
              if !search_options[:hidden_fields].blank?
                options[:html][:onsubmit] ||= ""
                options[:html][:onsubmit] += ";"
              
                javascript = "if(typeof(Prototype) != 'undefined') {"
                search_options[:hidden_fields].each { |field| javascript += "field = $('#{name}_#{field}'); if(field) { $('#{name}_#{field}_hidden').value = field.value; }" }
                javascript += "} else if(jQuery) {"
                search_options[:hidden_fields].each { |field| javascript += "field = $('##{name}_#{field}'); if(field) { $('##{name}_#{field}_hidden').val(field.val()); }" }
                javascript += "}"
              
                options[:html][:onsubmit] += javascript
              end
          
              # Setup options
              case first
              when Array
                first.pop
                first << search_object.klass.new
                options[:url] ||= polymorphic_path(first)
              else
                options[:url] ||= polymorphic_path(search_object.klass.new)
              end
          
              args << options
            end
          
            args
          end
        
          def insert_searchgasm_fields(args, search_object, search_options, &block)
            return unless search_object.is_a?(Search::Base)
            name = args.first
            options = args.extract_options!
            options
            search_options[:hidden_fields].each do |field|
              html = hidden_field(name, field, :object => search_object, :id => "#{name}_#{field}_hidden", :value => (field == :order_by ? searchgasm_base64_value(search_object.order_by) : search_object.send(field)))
              
              # For edge rails and older version compatibility, passing a binding to concat was deprecated
              begin
                concat(html)
              rescue ArgumentError
                concat(html, block.binding)
              end
            end
            args << options
          end
      end
      
      module Base # :nodoc:
        include Shared

        def fields_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            searchgasm_options = extract_searchgasm_options!(args)
            new_args = searchgasm_args(args, search_object, searchgasm_options, :fields_for)
            insert_searchgasm_fields(new_args, search_object, searchgasm_options, &block)
            fields_for_without_searchgasm(*new_args, &block)
          else
            fields_for_without_searchgasm(*args, &block)
          end
        end
      
        def form_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            searchgasm_options = extract_searchgasm_options!(args)
            form_for_without_searchgasm(*searchgasm_args(args, search_object, searchgasm_options, :form_for), &block)
          else
            form_for_without_searchgasm(*args, &block)
          end
        end
      
        def remote_form_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            searchgasm_options = extract_searchgasm_options!(args)
            remote_form_for_without_searchgasm(*searchgasm_args(args, search_object, searchgasm_options, :remote_form_for), &block)
          else
            remote_form_for_without_searchgasm(*args, &block)
          end
        end
      end
    
      module FormBuilder # :nodoc:
        include Shared
        
        def fields_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            searchgasm_options = extract_searchgasm_options!(args)
            new_args = searchgasm_args(args, search_object, searchgasm_options, :fields_for)
            insert_searchgasm_fields(new_args, search_object, searchgasm_options, &block)
            fields_for_without_searchgasm(*new_args, &block)
          else
            fields_for_without_searchgasm(*args, &block)
          end
        end
      end
    end
  end
end

if defined?(ActionView)
  ActionView::Base.send(:include, Searchgasm::Helpers::Form::Base)

  ActionView::Base.class_eval do
    alias_method_chain :fields_for, :searchgasm
    alias_method_chain :form_for, :searchgasm
    alias_method_chain :remote_form_for, :searchgasm
  end

  ActionView::Helpers::FormBuilder.send(:include, Searchgasm::Helpers::Form::FormBuilder)

  ActionView::Helpers::FormBuilder.class_eval do
    alias_method_chain :fields_for, :searchgasm
  end
end