module InheritedResources
  # = Dumb Responder
  #
  # This responder discards all messages sent to him.
  #
  class DumbResponder

    instance_methods.each do |m|
      undef_method m unless m =~ /^__/
    end

    # This is like a good husband, he will just listen everything that his wife
    # says (which is a lot) without complaining. :)
    #
    def method_missing(*args)
      nil
    end

  end
end
