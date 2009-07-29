module ActionController #:nodoc:
  class Base #:nodoc:

    # Defines mimes that are rendered by default when invoking respond_with.
    #
    # Examples:
    #
    #   respond_to :html, :xml, :json
    #
    # All actions on your controller will respond to :html, :xml and :json.
    #
    # But if you want to specify it based on your actions, you can use only and
    # except:
    #
    #   respond_to :html
    #   respond_to :xml, :json, :except => [ :edit ]
    #
    # The definition above explicits that all actions respond to :html. And all
    # actions except :edit respond to :xml and :json.
    #
    # You can specify also only parameters:
    #
    #   respond_to :rjs, :only => :create
    #
    def self.respond_to(*mimes)
      options = mimes.extract_options!

      only_actions   = Array(options.delete(:only))
      except_actions = Array(options.delete(:except))

      mimes.each do |mime|
        mime = mime.to_sym
        mimes_for_respond_to[mime]          = {}
        mimes_for_respond_to[mime][:only]   = only_actions   unless only_actions.empty?
        mimes_for_respond_to[mime][:except] = except_actions unless except_actions.empty?
      end
    end

    # Clear all mimes in respond_to.
    #
    def self.clear_respond_to
      write_inheritable_attribute(:mimes_for_respond_to, ActiveSupport::OrderedHash.new)
    end

    class_inheritable_reader :mimes_for_respond_to
    clear_respond_to

    # If ApplicationController is already defined around here, we have to set
    # mimes_for_respond_to hash as well.
    #
    ApplicationController.clear_respond_to if defined?(ApplicationController)

    def respond_to(*mimes, &block)
      options = mimes.extract_options!
      raise ArgumentError, "respond_to takes either types or a block, never both" if mimes.any? && block_given?

      resource  = options.delete(:with)
      responder = Responder.new(self)

      mimes = collect_mimes_from_class_level if mimes.empty?
      mimes.each { |mime| responder.send(mime) }
      block.call(responder) if block_given?

      if format = responder.negotiate_mime
        respond_to_block_or_template_or_resource(format, resource,
          options, &responder.response_for(format))
      else
        head :not_acceptable
      end
    end

    def respond_with(resource, options={}, &block)
      respond_to(options.merge!(:with => resource), &block)
    end

  protected

    def respond_to_block_or_template_or_resource(format, resource, options)
      response.template.template_format = format.to_sym
      response.content_type = format.to_s

      return yield if block_given?

      begin
        default_render
      rescue ActionView::MissingTemplate => e
        if resource && resource.respond_to?(:"to_#{format.to_sym}")
          render options.merge(format.to_sym => resource)
        else
          raise e
        end
      end
    end

    # Collect mimes declared in the class method respond_to valid for the
    # current action.
    #
    def collect_mimes_from_class_level #:nodoc:
      action = action_name.to_sym

      mimes_for_respond_to.keys.select do |mime|
        config = mimes_for_respond_to[mime]

        if config[:except]
          !config[:except].include?(action)
        elsif config[:only]
          config[:only].include?(action)
        else
          true
        end
      end
    end
  end

  module MimeResponds
    class Responder #:nodoc:
      attr_reader :order

      def any(*args, &block)
        if args.any?
          args.each { |type| send(type, &block) }
        else
          custom(Mime::ALL, &block)
        end
      end
      alias :all :any

      def custom(mime_type, &block)
        mime_type = mime_type.is_a?(Mime::Type) ? mime_type : Mime::Type.lookup(mime_type.to_s)
        @order << mime_type
        @responses[mime_type] ||= block
      end

      def response_for(mime)
        @responses[mime] || @responses[Mime::ALL]
      end

      def negotiate_mime
        @mime_type_priority.each do |priority|
          if priority == Mime::ALL
            return @order.first
          elsif @order.include?(priority)
            return priority
          end
        end

        if @order.include?(Mime::ALL)
          return Mime::SET.first if @mime_type_priority.first == Mime::ALL
          return @mime_type_priority.first
        end

        nil
      end
    end
  end
end
