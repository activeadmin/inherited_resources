module InheritedResources
  module ShallowHelpers
    include BelongsToHelpers

    private

      # Evaluate the parent given. This is used to nest parents in the
      # association chain.
      #

      # Maps parents_symbols to build association chain. In this case, it
      # simply return the parent_symbols, however on polymorphic belongs to,
      # it has some customization.
      #
      def symbols_for_association_chain #:nodoc:
        parent_symbols = parents_symbols.dup
        if parents_symbols.size > 1 && !params[:id]
          inst_class_name = parent_symbols.pop
          finder_method = resources_configuration[inst_class_name][:finder] || :find
          instance = resources_configuration[inst_class_name][:parent_class].send(finder_method, params[resources_configuration[inst_class_name][:param]])
          load_parents(instance, parent_symbols)
        end
        if params[:id]
          finder_method = resources_configuration[:self][:finder] || :find
          instance = self.resource_class.send(finder_method, params[:id])
          load_parents(instance, parent_symbols)
        end
        parents_symbols
      end

      def load_parents(instance, parent_symbols)

        parent_symbols.reverse.each do |parent|
          instance = instance.send(parent)
          params[resources_configuration[parent][:param]] = instance.to_param
        end
      end
  end

end
