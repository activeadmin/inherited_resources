module InheritedResources
  class Responder < ActionController::Responder
    include Responders::FlashResponder
  end
end
