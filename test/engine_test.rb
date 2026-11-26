# frozen_string_literal: true
require 'test_helper'

class EngineTest < ActiveSupport::TestCase
  def test_scaffold_generates_inherited_resources_controllers
    generators = InheritedResources::Railtie.config.app_generators

    assert_equal :inherited_resources_controller, generators.options[:rails][:scaffold_controller]
  end
end
