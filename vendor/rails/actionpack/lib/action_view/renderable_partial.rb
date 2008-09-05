module ActionView
  module RenderablePartial
    # NOTE: The template that this mixin is beening include into is frozen
    # So you can not set or modify any instance variables

    extend ActiveSupport::Memoizable

    def variable_name
      name.sub(/\A_/, '').to_sym
    end
    memoize :variable_name

    def counter_name
      "#{variable_name}_counter".to_sym
    end
    memoize :counter_name

    def render(view, local_assigns = {})
      if defined? ActionController
        ActionController::Base.benchmark("Rendered #{path_without_format_and_extension}", Logger::DEBUG, false) do
          super
        end
      else
        super
      end
    end

    def render_partial(view, object = nil, local_assigns = {}, as = nil)
      object ||= local_assigns[:object] ||
        local_assigns[variable_name]

      if view.respond_to?(:controller)
        object ||= ActiveSupport::Deprecation::DeprecatedObjectProxy.new(
          view.controller.instance_variable_get("@#{variable_name}"),
          "@#{variable_name} will no longer be implicitly assigned to #{variable_name}"
        )
      end

      # Ensure correct object is reassigned to other accessors
      local_assigns[:object] = local_assigns[variable_name] = object
      local_assigns[as] = object if as

      render_template(view, local_assigns)
    end
  end
end
