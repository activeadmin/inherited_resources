# frozen_string_literal: true

module InheritedResources
  # An object from BlankSlate simply discards all messages sent to it.
  class BlankSlate
    instance_methods.each do |m|
      undef_method m unless /^(__|object_id)/.match?(m)
    end

    def method_missing(*args)
      nil
    end
  end
end
