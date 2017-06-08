class <%= controller_class_name %>Controller < InheritedResources::Base
<% if options[:singleton] -%>
  defaults :singleton => true
<% end -%>
<% if Rails::VERSION::MAJOR >= 4 || defined?(ActiveModel::ForbiddenAttributesProtection) -%>

  private

    def <%= singular_name %>_params
      params.require(:<%= singular_name %>).permit(<%= attributes_names.map(&:to_sym).join(", ") %>)
    end
<% end -%>
end

