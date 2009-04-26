module ActionController
  # Provides an extension for Rails respond_to by expading MimeResponds::Responder
  # and adding respond_to class method and respond_with instance method.
  #
  class Base

    protected
      # Defines respond_to method to store formats that are rendered by default.
      #
      # Examples:
      #
      #   respond_to :html, :xml, :json
      #
      # All actions on your controller will respond to :html, :xml and :json.
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
      # Which would be the same as:
      #
      #   respond_to :rjs => :create
      #
      def self.respond_to(*formats)
        options = formats.extract_options!
        formats_hash = {}

        only_actions   = Array(options.delete(:only))
        except_actions = Array(options.delete(:except))

        only_actions.map!{ |a| a.to_sym }
        except_actions.map!{ |a| a.to_sym }

        formats.each do |format|
          formats_hash[format.to_sym]          = {}
          formats_hash[format.to_sym][:only]   = only_actions   unless only_actions.empty?
          formats_hash[format.to_sym][:except] = except_actions unless except_actions.empty?
        end

        options.each do |format, actions|
          formats_hash[format.to_sym] = {}
          next if actions == :all || actions == 'all'

          actions = Array(actions)
          actions.map!{ |a| a.to_sym }

          formats_hash[format.to_sym][:only] = actions unless actions.empty?
        end

        write_inheritable_hash(:formats_for_respond_to, formats_hash)
      end
      class_inheritable_reader :formats_for_respond_to

      # By default, responds only to :html
      respond_to :html

      # Method to clear all respond_to declared until the current controller.
      # This is like freeing the controller from the inheritance chain. :)
      #
      def self.clear_respond_to!
        formats = formats_for_respond_to
        formats.each { |k,v| formats[k] = { :only => [] } }
        write_inheritable_hash(:formats_for_respond_to, formats)
      end

      # respond_with accepts an object and tries to render a view based in the
      # controller and actions that called respond_with. If the view cannot be
      # found, it will try to call :to_format in the object.
      #
      #   class ProjectsController < ApplicationController
      #     respond_to :html, :xml
      #
      #     def show
      #       @project = Project.find(:id)
      #       respond_with(@project)
      #     end
      #   end
      #
      # When the client request a xml, we will check first for projects/show.xml
      # if it can't be found, we will call :to_xml in the object @project. If the
      # object eventually doesn't respond to :to_xml it will render 404.
      #
      # If you want to overwrite the formats specified in the class, you can
      # send your new formats using the options :to.
      #
      #     def show
      #       @project = Project.find(:id)
      #       respond_with(@project, :to => :json)
      #     end
      #
      # That means that this action will ONLY reply to json requests.
      #
      # All other options sent will be forwarded to the render method. So you can
      # do:
      #
      #    def create
      #       # ... 
      #       if @project.save
      #         respond_with(@project, :status => :ok, :location => @project)
      #       else
      #         respond_with(@project.errors, :status => :unprocessable_entity)
      #      end
      #    end
      #
      # respond_with does not accept blocks, if you want advanced configurations
      # check respond_to method sending :with => @object as option.
      #
      # Returns true if anything is rendered. Returns false otherwise.
      #
      def respond_with(object, options = {})
        attempt_to_respond = false

        responder             = options.delete(:responder) || Responder.new(self)
        skip_not_acceptable   = options.delete(:skip_not_acceptable)
        skip_default_template = options.delete(:skip_default_template)

        mime_types = Array(options.delete(:to))
        mime_types.map!{ |mime| mime.to_sym }

        for priority in responder.mime_type_priority
          if !skip_default_template && priority == Mime::ALL && respond_to_default_template?(responder)
            render options.merge(:action => action_name)
            return true

          elsif responder.action_respond_to_format?(priority.to_sym, mime_types)
            attempt_to_respond = true
            response.template.template_format = priority.to_sym
            response.content_type = priority.to_s

            if template_exists?
              render options.merge(:action => action_name)
              return true
            elsif object.respond_to?(:"to_#{priority.to_sym}")
              render options.merge(:text => object.send(:"to_#{priority.to_sym}"))
              return true
            end
          end
        end

        # If we got here we could not render the object. But if attempted to
        # render (this means, the format sent by the client was valid) we should
        # render a 404.
        #
        # If we even didn't attempt to respond, we respond :not_acceptable
        # unless is told otherwise.
        #
        if attempt_to_respond
          render :text => '404 Not Found', :status => 404
          return true
        elsif !skip_not_acceptable
          head :not_acceptable
          return false
        end

        return false
      end

      # Extends respond_to behaviour.
      #
      # You can now pass objects using the options :with.
      #
      #   respond_to(:html, :xml, :rjs, :with => @project)
      #
      # If you pass an object and send any block, it's exactly the same as:
      #
      #   respond_with(@project, :to => [:html, :xml, :rjs])
      #
      # But the main difference of respond_to and respond_with is that the first
      # allows further customizations:
      #
      #   respond_to(:html, :with => @project) do |format|
      #     format.xml { render :xml => @project.errors  }
      #   end
      #
      # It's the same as:
      #
      #   1. When responding to html, execute respond_with(@object).
      #   2. When accessing a xml, execute the block given.
      #
      # Formats defined in blocks have precedence to formats sent as arguments.
      # In other words, if you pass a format as argument and as block, the block
      # will always be executed.
      #
      # And as in respond_with, all extra options sent will be forwarded to 
      # the render method:
      #
      #   respond_to(:with => @projects.errors, :status => :unprocessable_entity) do |format|
      #     format.html { render :template => 'new' }
      #   end
      #
      # It also accepts an option called prioritize. It allows you to put a
      # format as first, and then when Mime::ALL is sent, it will be the one
      # used as response.
      #
      def respond_to(*types, &block)
        options = types.extract_options!

        object     = options.delete(:with)
        responder  = options.delete(:responder) || Responder.new(self)
        prioritize = options.delete(:prioritize)

        if object.nil?
          block ||= lambda { |responder| types.each { |type| responder.send(type) } }
          block.call(responder)
          responder.respond
          return true
        else
          # Even if Mime::ALL is sent by the client, we do not respond_to it now.
          # This is done using calling :respond_except_any instead of :respond.
          #
          if block_given?
            block.call(responder)
            return true if responder.respond_except_any
          end

          # If the block includes the default template format, we don't render
          # the default template (which uses the default_template_format).
          options.merge!(:to => types, :responder => responder, :skip_not_acceptable => true,
                         :skip_default_template => responder.order.include?(default_template_format))

          if respond_with(object, options)
            return true
          elsif block_given?
            responder.prioritize(prioritize) if prioritize
            return true if responder.respond_any
          end
        end

        head :not_acceptable
        return false
      end

    private

      unless ActionController::Base.private_instance_methods.include?('template_exists?') ||
             ActionController::Base.private_instance_methods.include?(:template_exists?)

        # Define template_exists? for Rails 2.3
        def template_exists?
          default_template ? true : false
        rescue ActionView::MissingTemplate
          false
        end
      end

      # We respond to the default template if it's a valid format AND the template
      # exists.
      #
      def respond_to_default_template?(responder) #:nodoc:
        responder.action_respond_to_format?(default_template_format) && template_exists?
      end

      # If ApplicationController is already defined around here, we should call
      # inherited_with_inheritable_attributes to insert formats_for_respond_to.
      # This usually happens only on Rails 2.3.
      #
      if defined?(ApplicationController)
        self.send(:inherited_with_inheritable_attributes, ApplicationController)
      end

  end

  module MimeResponds #:nodoc:
    class Responder #:nodoc:

      attr_reader :mime_type_priority, :order

      # Similar as respond but if we can't find a valid mime type, we do not
      # send :not_acceptable message as head and it does not respond to
      # Mime::ALL in any case.
      #
      def respond_except_any
        for priority in @mime_type_priority
          next if priority == Mime::ALL

          if @responses[priority]
            @responses[priority].call
            return true
          end
        end

        false
      end

      # Respond to the first format given if Mime::ALL is included in the
      # mime type priorites. This is the behaviour expected when the client
      # sends "*/*" as mime type.
      #
      def respond_any
        any = @responses[@order.include?(Mime::ALL) ? Mime::ALL : @order.first]

        if any && @mime_type_priority.include?(Mime::ALL)
          any.call
          return true
        end
      end

      # Receives an format and checks if the current action responds to
      # the given format. If additional mimes are sent, only them are checked.
      #
      def action_respond_to_format?(format, additional_mimes = [])
        if !additional_mimes.blank?
          additional_mimes.include?(format.to_sym)
        elsif formats = @controller.formats_for_respond_to[format.to_sym]
          if formats[:only]
            formats[:only].include?(@controller.action_name.to_sym)
          elsif formats[:except]
            !formats[:except].include?(@controller.action_name.to_sym)
          else
            true
          end
        else
          false
        end
      end

      # Makes a given format the first in the @order array.
      #
      def prioritize(format)
        if index = @order.index(format)
          @order.unshift(@order.delete_at(index))
        end
        @order
      end

    end
  end
end
