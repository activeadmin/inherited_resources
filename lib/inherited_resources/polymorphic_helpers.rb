module InheritedResources #:nodoc:
  module PolymorphicHelpers #:nodoc:

    protected

      def parent_type
        @parent_type
      end

      def parent_class
        parent_instance.class
      end

      def parent_instance
        instance_variable_get("@#{@parent_type}")
      end
  end
end

