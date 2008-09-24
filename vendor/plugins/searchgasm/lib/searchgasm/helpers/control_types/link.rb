module Searchgasm
  module Helpers
    # = Control Type Helpers
    #
    # The purpose of these helpers is to make ordering and paginating data, in your view, a breeze. Everyone has their own flavor of displaying data, so I made these helpers extra flexible, just for you.
    #
    # === Tutorial
    #
    # Check out my tutorial on how to implement searchgasm into a rails app: http://www.binarylogic.com/2008/9/7/tutorial-pagination-ordering-and-searching-with-searchgasm
    #
    # === How it's organized
    #
    # If we break it down, you can do 4 different things with your data in your view:
    #
    # 1. Order your data by a single column or an array of columns
    # 2. Descend or ascend your data
    # 3. Change how many items are on each page
    # 4. Paginate through your data
    #
    # Each one of these actions comes with 3 different types of helpers:
    #
    # 1. Link - A single link for a single value. Requires that you pass a value as the first parameter.
    # 2. Links - A group of single links.
    # 3. Select - A select with choices that perform an action once selected. Basically the same thing as a group of links, but just as a select form element
    # 4. Remote - lets you prefix any of these helpers with "remote_" and it will use the built in rails ajax helpers. I highly recommend unobstrusive javascript though, using jQuery.
    #
    # === Examples
    #
    # Sometimes the best way to explain something is with some examples. Let's pretend we are performing these actions on a User model. Check it out:
    #
    #   order_by_link(:name)
    #   => produces a single link that when clicked will order by the name column, and each time its clicked alternated between "ASC" and "DESC"
    #
    #   order_by_links
    #   => produces a group of links for all of the columns in your users table, each link is basically order_by_link(column.name)
    #
    #   order_by_select
    #   => produces a select form element with all of the user's columns as choices, when the value is change (onchange) it will act as if they clicked a link.
    #   => This is just order_by_links as a select form element, nothing fancy
    #
    # What about paginating? I got you covered:
    #
    #   page_link(2)
    #   => creates a link to page 2
    #
    #   page_links
    #   => creates a group of links for pages, similar to a flickr style of pagination
    #
    #   page_select
    #   => creates a drop down instead of a group of links. The user can select the page in the drop down and it will be as if they clicked a link for that page.
    #
    # You can apply the _link, _links, or _select to any of the following: order_by, order_as, per_page, page. You have your choice on how you want to set up the interface. For more information and options on these individual
    # helpers check out their source files. Look at the sub modules under this one (Ex: Searchgasm::Helpers::ControlTypes::Select)
    module ControlTypes
      # = Link Control Types
      #
      # These helpers make ordering and paginating your data a breeze in your view. They only produce links.
      module Link
        # Creates a link for ordering data by a column or columns
        #
        # === Example uses for a User class that has many orders
        #
        #   order_by_link(:first_name)
        #   order_by_link([:first_name, :last_name])
        #   order_by_link({:orders => :total})
        #   order_by_link([{:orders => :total}, :first_name])
        #   order_by_link(:id, :text => "Order Number", :html => {:class => "order_number"})
        #
        # What's nifty about this is that the value gets "serialized", if it is not a string or a symbol, so that it can be passed via a param in the url. Searchgasm will automatically try to "unserializes" this value and use it. This allows you
        # to pass complex objects besides strings and symbols, such as arrays and hashes. All of the hard work is done for you.
        #
        # Another thing to keep in mind is that this will alternate between "asc" and "desc" each time it is clicked.
        #
        # === Options
        # * <tt>:text</tt> -- default: column_name.to_s.humanize, text for the link
        # * <tt>:desc_indicator</tt> -- default: &nbsp;&#9660;, the indicator that this column is descending
        # * <tt>:asc_indicator</tt> -- default: &nbsp;&#9650;, the indicator that this column is ascending
        # * <tt>:html</tt> -- html arrtributes for the <a> tag.
        #
        # === Advanced Options
        # * <tt>:params_scope</tt> -- default: :search, this is the scope in which your search params will be preserved (params[:search]). If you don't want a scope and want your options to be at base leve in params such as params[:page], params[:per_page], etc, then set this to nil.
        # * <tt>:search_obj</tt> -- default: @#{params_scope}, this is your search object, everything revolves around this. It will try to infer the name from your params_scope. If your params_scope is :search it will try to get @search, etc. If it can not be inferred by this, you need to pass the object itself.
        # * <tt>:url_params</tt> -- default: nil, Additional params to add to the url, must be a hash
        def order_by_link(order_by, options = {})
          order_by = deep_stringify(order_by)
          add_order_by_link_defaults!(order_by, options)
          html = searchgasm_state_for(:order_by, options) + searchgasm_state_for(:order_as, options)
          
          if !options[:is_remote]
            html += link_to(options[:text], options[:url], options[:html])
          else
            html += link_to_remote(options[:text], options[:remote].merge(:url => options[:url]), options[:html])
          end
          
          html
        end
        
        # Creates a link for ascending or descending data, pretty self e
        #
        # === Example uses
        #
        #   order_as_link("asc")
        #   order_as_link("desc")
        #   order_as_link("asc", :text => "Ascending", :html => {:class => "ascending"})
        #
        # === Options
        # * <tt>:text</tt> -- default: column_name.to_s.humanize, text for the link
        # * <tt>:html</tt> -- html arrtributes for the <a> tag.
        #
        # === Advanced Options
        # * <tt>:params_scope</tt> -- default: :search, this is the scope in which your search params will be preserved (params[:search]). If you don't want a scope and want your options to be at base leve in params such as params[:page], params[:per_page], etc, then set this to nil.
        # * <tt>:search_obj</tt> -- default: @#{params_scope}, this is your search object, everything revolves around this. It will try to infer the name from your params_scope. If your params_scope is :search it will try to get @search, etc. If it can not be inferred by this, you need to pass the object itself.
        # * <tt>:url_params</tt> -- default: nil, Additional params to add to the url, must be a hash
        def order_as_link(order_as, options = {})
          add_order_as_link_defaults!(order_as, options)
          html = searchgasm_state_for(:order_as, options)
          
          if !options[:is_remote]
            html += link_to(options[:text], options[:url], options[:html])
          else
            html += link_to_remote(options[:text], options[:remote].merge(:url => options[:url]), options[:html])
          end
          
          html
        end
        
        # Creates a link for limiting how many items are on each page
        #
        # === Example uses
        #
        #   per_page_link(200)
        #   per_page_link(nil) # => Show all
        #   per_page_link(nil, :text => "All", :html => {:class => "show_all"})
        #
        # As you can see above, passing nil means "show all" and the text will automatically revert to "show all"
        #
        # === Options
        # * <tt>:text</tt> -- default: column_name.to_s.humanize, text for the link
        # * <tt>:html</tt> -- html arrtributes for the <a> tag.
        #
        # === Advanced Options
        # * <tt>:params_scope</tt> -- default: :search, this is the scope in which your search params will be preserved (params[:search]). If you don't want a scope and want your options to be at base leve in params such as params[:page], params[:per_page], etc, then set this to nil.
        # * <tt>:search_obj</tt> -- default: @#{params_scope}, this is your search object, everything revolves around this. It will try to infer the name from your params_scope. If your params_scope is :search it will try to get @search, etc. If it can not be inferred by this, you need to pass the object itself.
        # * <tt>:url_params</tt> -- default: nil, Additional params to add to the url, must be a hash
        def per_page_link(per_page, options = {})
          add_per_page_link_defaults!(per_page, options)
          html = searchgasm_state_for(:per_page, options)
          
          if !options[:is_remote]
            html += link_to(options[:text], options[:url], options[:html])
          else
            html += link_to_remote(options[:text], options[:remote].merge(:url => options[:url]), options[:html])
          end
          
          html
        end
        
        # Creates a link for changing to a sepcific page of your data
        #
        # === Example uses
        #
        #   page_link(2)
        #   page_link(1)
        #   page_link(5, :text => "Fifth page", :html => {:class => "fifth_page"})
        #
        # === Options
        # * <tt>:text</tt> -- default: column_name.to_s.humanize, text for the link
        # * <tt>:html</tt> -- html arrtributes for the <a> tag.
        #
        # === Advanced Options
        # * <tt>:params_scope</tt> -- default: :search, this is the scope in which your search params will be preserved (params[:search]). If you don't want a scope and want your options to be at base leve in params such as params[:page], params[:per_page], etc, then set this to nil.
        # * <tt>:search_obj</tt> -- default: @#{params_scope}, this is your search object, everything revolves around this. It will try to infer the name from your params_scope. If your params_scope is :search it will try to get @search, etc. If it can not be inferred by this, you need to pass the object itself.
        # * <tt>:url_params</tt> -- default: nil, Additional params to add to the url, must be a hash
        def page_link(page, options = {})
          add_page_link_defaults!(page, options)
          html = searchgasm_state_for(:page, options)
          
          if !options[:is_remote]
            html += link_to(options[:text], options[:url], options[:html])
          else
            html += link_to_remote(options[:text], options[:remote].merge(:url => options[:url]), options[:html])
          end
          
          html
        end
        
        private
          def add_order_by_link_defaults!(order_by, options = {})
            add_searchgasm_control_defaults!(:order_by, options)
            options[:text] ||= determine_order_by_text(order_by)
            options[:asc_indicator] ||= Config.asc_indicator
            options[:desc_indicator] ||= Config.desc_indicator
            options[:text] += options[:search_obj].desc? ? options[:desc_indicator] : options[:asc_indicator] if options[:search_obj].order_by == order_by
            options[:url] = searchgasm_params(options.merge(:search_params => {:order_by => order_by}))
            options
          end
          
          def add_order_as_link_defaults!(order_as, options = {})
            add_searchgasm_control_defaults!(:order_as, options)
            options[:text] ||= order_as.to_s
            options[:url] = searchgasm_params(options.merge(:search_params => {:order_as => order_as}))
            options
          end
          
          def add_per_page_link_defaults!(per_page, options = {})
            add_searchgasm_control_defaults!(:per_page, options)
            options[:text] ||= per_page.blank? ? "Show all" : "#{per_page} per page"
            options[:url] = searchgasm_params(options.merge(:search_params => {:per_page => per_page}))
            options
          end
          
          def add_page_link_defaults!(page, options = {})
            add_searchgasm_control_defaults!(:page, options)
            options[:text] ||= page.to_s
            options[:url] = searchgasm_params(options.merge(:search_params => {:page => page}))
            options
          end
          
          def determine_order_by_text(column_name, relationship_name = nil)
            case column_name
            when String, Symbol
              relationship_name.blank? ? column_name.to_s.titleize : "#{relationship_name.to_s.titleize} #{column_name.to_s.titleize}"
            when Array
              determine_order_by_text(column_name.first)
            when Hash
              k = column_name.keys.first
              v = column_name.values.first
              determine_order_by_text(v, k)
            end
          end
          
          def deep_stringify(obj)
            case obj
            when String
              obj
            when Symbol
              obj = obj.to_s
            when Array
              obj = obj.collect { |item| deep_stringify(item) }
            when Hash
              new_obj = {}
              obj.each { |key, value| new_obj[key.to_s] = deep_stringify(value) }
              new_obj
            end
          end
      end
    end
  end
end

ActionController::Base.helper Searchgasm::Helpers::ControlTypes::Link if defined?(ActionController)