require File.expand_path('test_helper', File.dirname(__FILE__))

class Vehicle
  extend ActiveModel::Naming
end

class Wheel
  extend ActiveModel::Naming
end

class WheelsController < InheritedResources::Base
  belongs_to :vehicle, :scope => :in_stock
end

class ParentScopesTest < ActionController::TestCase
  tests WheelsController

  def test_parent_scope
    Vehicle.expects(:in_stock).returns(Vehicle)
    Vehicle.expects(:find).with('21').returns(mock_vehicle)
    mock_vehicle.expects(:wheels).returns(Wheel)
    mock_vehicle.stubs(:class).returns(Vehicle)
    Wheel.expects(:scoped).returns([mock_wheel])
    get :index, :vehicle_id => '21'

    assert_equal mock_vehicle, @controller.send(:parent)
  end

  protected

    def mock_vehicle(stubs={})
      @mock_vehicle ||= mock(stubs)
    end

    def mock_wheel(stubs={})
      @mock_wheel ||= mock(stubs)
    end

end
