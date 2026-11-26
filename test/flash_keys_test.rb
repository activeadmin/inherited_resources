# frozen_string_literal: true
require 'test_helper'

class FlashKeysTest < ActiveSupport::TestCase
  def setup
    @original_flash_keys = Responders::FlashResponder.flash_keys
  end

  def teardown
    Responders::FlashResponder.flash_keys = @original_flash_keys
  end

  def test_flash_keys_are_set_on_the_flash_responder
    InheritedResources.flash_keys = [:success, :failure]

    assert_equal [:success, :failure], Responders::FlashResponder.flash_keys
  end
end
