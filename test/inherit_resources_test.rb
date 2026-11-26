# frozen_string_literal: true
require 'test_helper'

# Covers controllers that call `inherit_resources` instead of inheriting from
# InheritedResources::Base, e.g. to keep their own superclass.
class InheritResourcesTest < ActiveSupport::TestCase
  def test_responds_to_html_when_no_formats_are_declared
    controller = build_gadgets_controller

    assert_equal [:html], controller.mimes_for_respond_to.keys
  end

  def test_keeps_formats_declared_before_inherit_resources
    controller = build_gadgets_controller { respond_to :json }

    assert_equal [:json], controller.mimes_for_respond_to.keys
  end

  def test_keeps_a_resource_class_declared_before_inherit_resources
    model = Class.new
    controller = build_gadgets_controller { class_attribute :resource_class, default: model }

    assert_same model, controller.send(:resource_class)
  end

  def test_looks_up_the_resource_class_when_none_is_declared
    stub_const(Object, :Gadget, Class.new, exists: false) do
      assert_same Gadget, build_gadgets_controller.send(:resource_class)
    end
  end

  private

    # Like build_controller, but runs the block before `inherit_resources`.
    def build_gadgets_controller(&before_inherit_resources)
      Class.new(ApplicationController) do
        def self.name
          'GadgetsController'
        end

        class_eval(&before_inherit_resources) if before_inherit_resources
        inherit_resources
      end
    end
end
