# This is a nasty rspec bug fix when using InheritedResources.
# The bug exists on rspec <= 1.1.12 versions.
#
if defined?(Spec::Rails::Example::ControllerExampleGroup)
  unless Spec::Rails::Example::ControllerExampleGroup.const_defined?('TemplateIsolationExtensions')

    module Spec::Rails::Example
      class ControllerExampleGroup < FunctionalExampleGroup
        module ControllerInstanceMethods #:nodoc:

          # === render(options = nil, deprecated_status_or_extra_options = nil, &block)
          #
          # This gets added to the controller's singleton meta class,
          # allowing Controller Examples to run in two modes, freely switching
          # from context to context.
          def render(options=nil, deprecated_status_or_extra_options=nil, &block)
            if ::Rails::VERSION::STRING >= '2.0.0' && deprecated_status_or_extra_options.nil?
              deprecated_status_or_extra_options = {}
            end

            unless block_given?
              unless integrate_views?
                if @template.respond_to?(:finder)
                  (class << @template.finder; self; end).class_eval do
                    define_method :file_exists? do; true; end
                  end
                else
                  (class << @template; self; end).class_eval do
                    define_method :file_exists? do; true; end
                  end
                end

                (class << @template; self; end).send :include, TemplateIsolationExtensions
              end
            end

            if matching_message_expectation_exists(options)
              render_proxy.render(options, &block)
              @performed_render = true
            else
              if matching_stub_exists(options)
                @performed_render = true
              else
                super(options, deprecated_status_or_extra_options, &block)
              end
            end
          end
        end

        module TemplateIsolationExtensions
          def render_file(*args)
            @first_render ||= args[0] unless args[0] =~ /^layouts/
            @_first_render ||= args[0] unless args[0] =~ /^layouts/
          end

          def _pick_template(*args)
            @_first_render ||= args[0] unless args[0] =~ /^layouts/
            PickedTemplate.new
          end

          def render(*args)
            if @_rendered
              opts = args[0]
              (@_rendered[:template] ||= opts[:file]) if opts[:file]
              (@_rendered[:partials][opts[:partial]] += 1) if opts[:partial]
            else
              super
            end
          end
        end
      end
    end

  end
end
