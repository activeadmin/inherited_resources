module InheritedResources
  # Allows controllers to write actions using a class method DSL.
  #
  #   class MyController < InheritedResources::Base
  #     create! do |success, failure|
  #       success.html { render :text => "It works!" }
  #     end
  #   end
  #
  module DSL
    def self.included(base)
      ACTIONS.each do |action|
        base.class_eval <<-WRITTER
          def self.#{action}!(options={}, &block)
            define_method #{action.inspect}!, &block
            class_eval <<-ACTION
              def #{action}
                super(\#{options.inspect}, &method(#{action.inspect}!))
              end
            ACTION
          end
        WRITTER
      end
    end
  end
end
