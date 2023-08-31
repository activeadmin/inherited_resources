module InheritedResources
  class Responder < ActionController::Responder
    include Responders::FlashResponder
    include Responders::HttpCacheResponder
  
    # Configure default status codes for responding to errors and redirects.
    self.error_status = :unprocessable_entity
    self.redirect_status = :see_other
  end
end
