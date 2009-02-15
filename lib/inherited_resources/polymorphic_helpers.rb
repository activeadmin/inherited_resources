module InheritedResources #:nodoc:
  module PolymorphicHelpers #:nodoc:

    protected

      def parent_type
        @parent_type
      end

      def parent_class
        parent.class if @parent_type
      end

      def parent
        instance_variable_get("@#{@parent_type}") if @parent_type
      end

    private

      def parent?
        if resources_configuration[:polymorphic][:optional]
          !@parent_type.nil?
        else
          true
        end
      end

      # Maps parents_symbols to build association chain.
      #
      # If the parents_symbols find :polymorphic, it goes through the
      # params keys to see which polymorphic parent matches the given params.
      #
      # When optional is given, it does not raise errors if the polymorphic
      # params are missing.
      #
      def symbols_for_chain
        polymorphic_config = resources_configuration[:polymorphic]

        parents_symbols.map do |symbol|
          if symbol == :polymorphic
            params_keys = params.keys

            key = polymorphic_config[:symbols].find do |poly|
              params_keys.include? resources_configuration[poly][:param].to_s
            end

            if key.nil?
              raise ScriptError, "Could not find param for polymorphic association.
                                  The request params keys are #{params.keys.inspect}
                                  and the polymorphic associations are
                                  #{polymorphic_symbols.inspect}." unless polymorphic_config[:optional]

              nil
            else
              @parent_type = key.to_sym
            end
          else
            symbol
          end
        end.compact
      end

  end
end

