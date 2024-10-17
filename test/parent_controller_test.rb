require 'test_helper'

def force_parent_controller(value)
  InheritedResources.send(:remove_const, :Base)
  InheritedResources.parent_controller = value
  load File.join(__dir__, '..', 'app', 'controllers', 'inherited_resources', 'base.rb')
end

class ParentControllerTest < ActionController::TestCase
  def test_setting_parent_controller
    original_parent = InheritedResources::Base.superclass

    assert_equal ApplicationController, original_parent

    force_parent_controller('ActionController::Base')

    assert_equal ActionController::Base, InheritedResources::Base.superclass
  ensure
    force_parent_controller(original_parent.to_s) # restore original parent
  end
end
