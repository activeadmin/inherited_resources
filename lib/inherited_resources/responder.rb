# frozen_string_literal: true

module InheritedResources
  class Responder < ActionController::Responder
    include Responders::FlashResponder

    self.error_status = :unprocessable_entity
    self.redirect_status = :see_other
  end
end
