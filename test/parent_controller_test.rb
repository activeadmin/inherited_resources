# frozen_string_literal: true
require 'test_helper'

class ParentControllerTest < ActionController::TestCase
  BASE_PATH = File.expand_path('../app/controllers/inherited_resources/base.rb', __dir__)

  def setup
    @original_parent_controller = InheritedResources.parent_controller
  end

  def teardown
    InheritedResources.parent_controller = @original_parent_controller
  end

  def test_setting_parent_controller
    original_base = InheritedResources::Base

    assert_equal ApplicationController, original_base.superclass

    # Every controller in the suite inherits from the original Base class, so
    # stub_const puts that exact class back afterwards.
    stub_const(InheritedResources, :Base, InheritedResources::Base) do
      InheritedResources.parent_controller = 'ActionController::Base'
      InheritedResources.send(:remove_const, :Base)
      # Evaluate rather than load the file: loading it again would reset its
      # coverage, dropping what earlier tests recorded for it.
      eval(File.read(BASE_PATH), TOPLEVEL_BINDING, BASE_PATH)

      assert_equal ActionController::Base, InheritedResources::Base.superclass
    end

    assert_same original_base, InheritedResources::Base
  end
end
