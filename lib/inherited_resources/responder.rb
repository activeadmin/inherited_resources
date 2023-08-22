# frozen_string_literal: true

module InheritedResources
  class Responder < ActionController::Responder
    include Responders::FlashResponder
  end
end
