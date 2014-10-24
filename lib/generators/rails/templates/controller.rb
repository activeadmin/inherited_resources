class <%= controller_class_name %>Controller < InheritedResources::Base
<% if options[:singleton] -%>
  defaults :singleton => true
<% end -%>

private

  def <%= singular_name %>_params
    params.require(:<%= singular_name %>).permit(<%= attributes_names.map{ |a_name| ":#{a_name}" }.join(", ") %>)
  end

end

