# Provides an extension for Rails respond_to by expading MimeResponds::Responder
# and adding respond_to class method and respond_with instance method.
#
module ActionController #:nodoc:
  class Base #:nodoc:

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

      # Define defaults respond_to
      respond_to :html
      respond_to :xml, :except => [ :edit ]

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

        # You can also send a responder object as parameter.
        #
        responder = options.delete(:responder) || Responder.new(self)

        # Check for given mime types
        #
        mime_types = Array(options.delete(:to))
        mime_types.map!{ |mime| mime.to_sym }

        # If :skip_not_acceptable is sent, it will not render :not_acceptable
        # if the mime type sent by the client cannot be found.
        #
        skip_not_acceptable = options.delete(:skip_not_acceptable)

        for priority in responder.mime_type_priority
          if priority == Mime::ALL && template_exists?
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
      def respond_to(*types, &block)
        options = types.extract_options!
        object = options.delete(:with)
        responder = Responder.new(self)
        
        # This is the default respond_to behaviour, when no object is given.
        if object.nil?
          block ||= lambda { |responder| types.each { |type| responder.send(type) } }
          block.call(responder)
          responder.respond
          return true # we are done here

        else
          # If a block is given, it checks if we can perform the requested format.
          #
          # Even if Mime::ALL is sent by the client, we do not respond_to it now.
          # This is done using calling :respond_to_block instead of :respond.
          #
          # It's worth to remember that responder_to_block does not respond
          # :not_acceptable also.
          #
          if block_given?
            block.call(responder)
            responder.respond_to_block
            return true if responder.responded? || performed?
          end

          # Let's see if we get lucky rendering with :respond_with.
          # At the end, respond_with checks for Mime::ALL if any template exist.
          #
          # Notice that we are sending the responder (for performance gain) and
          # sending :skip_not_acceptable because we don't want to respond
          # :not_acceptable yet.
          #
          if respond_with(object, options.merge(:to => types, :responder => responder, :skip_not_acceptable => true))
            return true

          # Since respond_with couldn't help us, our last chance is to reply to
          # any block given if the user send all as mime type.
          #
          elsif block_given?
            return true if responder.respond_to_all
          end
        end

        # If we get here it means that we could not satisfy our request.
        # Now we finally return :not_acceptable.
        #
        head :not_acceptable
        return false
      end

    private

      # Define template_exists? for Rails 2.3
      unless ActionController::Base.private_instance_methods.include? 'template_exists?'
        def template_exists?
          self.view_paths.find_template("#{controller_name}/#{action_name}", response.template.template_format)
        rescue ActionView::MissingTemplate
          false
        end
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

      # Create an attr_reader for @mime_type_priority
      attr_reader :mime_type_priority

      # Stores if this Responder instance called any block.
      def responded?; @responded; end

      # Similar as respond but if we can't find a valid mime type,
      # we do not send :not_acceptable message as head.
      #
      # It does not respond to Mime::ALL in priority as well.
      #
      def respond_to_block
        for priority in @mime_type_priority
          next if priority == Mime::ALL

          if @responses[priority]
            @responses[priority].call
            return (@responded = true) # mime type match found, be happy and return
          end
        end

        if @order.include?(Mime::ALL)
          @responses[Mime::ALL].call
          return (@responded = true)
        else
          return (@responded = false)
        end
      end

      # Respond to the first format given if Mime::ALL is included in the
      # mime type priorites. This is the behaviour expected when the client
      # sends "*/*" as mime type.
      #
      def respond_to_all
        if @mime_type_priority.include?(Mime::ALL) && first = @responses[@order.first]
          first.call
          return (@responded = true)
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

    end
  end
end
