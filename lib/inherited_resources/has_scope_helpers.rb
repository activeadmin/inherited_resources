module InheritedResources

  # = has_scopes
  #
  # This module in included in your controller when has_scope is called for the
  # first time.
  #
  module HasScopeHelpers
    TRUE_VALUES = ["true", true, "1", 1] unless self.const_defined?(:TRUE_VALUES)

    protected

      # Overwrites apply to scope to implement default scope logic.
      #
      def apply_scope_to(target_object, target_name) #:nodoc:
        @current_scopes ||= {}
        scope_config = self.scopes_configuration[target_name] || {}

        scope_config.each do |scope, options|
          next unless apply_scope_to_action?(options)
          key = options[:key]

          if params.key?(key)
            value = @current_scopes[key] = params[key]

            if options[:boolean]
              target_object = target_object.send(scope) if TRUE_VALUES.include?(value)
            else
              target_object = target_object.send(scope, *value)
            end
          end
        end

        target_object
      end

      # Given an options with :only and :except arrays, check if the scope
      # can be performed in the current action.
      #
      def apply_scope_to_action?(options) #:nodoc:
        if formats[:only].empty?
          if formats[:except].empty?
            true
          else
            !formats[:except].include?(action_name.to_sym)
          end
        else
          formats[:only].include?(action_name.to_sym)
        end
      end

      # Returns the scopes used in this action.
      #
      def current_scopes
        @current_scopes || {}
      end

  end
end
