require 'test_helper'

# This test file is instead to test the how controller flow and actions
# using a belongs_to association. This is done using mocks a la rspec.
#
class Party
  extend ActiveModel::Naming
end

class Venue
  extend ActiveModel::Naming
end

class Address
  extend ActiveModel::Naming
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular "address", "address"
  inflect.plural   "address", "addresses"
end

class VenueController < InheritedResources::Base
  defaults singleton: true
  belongs_to :party
end

# for the slightly pathological
# /party/37/venue/address case
class AddressController < InheritedResources::Base
  defaults singleton: true
  belongs_to :party do
    belongs_to :venue, singleton: true
  end
end

#and the more pathological case
class GeolocationController < InheritedResources::Base
  defaults singleton: true
  belongs_to :party do
    belongs_to :venue, singleton: true do
      belongs_to :address, singleton: true
    end
  end
end

class NestedSingletonTest < ActionController::TestCase
  tests AddressController

  def setup
    @controller.stubs(:resource_url).returns('/')
    @controller.stubs(:collection_url).returns('/')
  end

  def test_does_not_break_parent_controller
    #this is kind of tacky, but seems to work
    old_controller = @controller
    @controller = VenueController.new
    Party.expects(:find).with('37').returns(mock_party)
    mock_party.expects(:venue).returns(mock_venue)
    get :show, params: { party_id: '37' }
    assert_equal mock_party, assigns(:party)
    assert_equal mock_venue, assigns(:venue)
  ensure
    @controller = old_controller
  end

  def test_does_not_break_child_controller
    #this is kind of tacky, but seems to work
    old_controller = @controller
    @controller = GeolocationController.new
    Party.expects(:find).with('37').returns(mock_party)
    mock_party.expects(:venue).returns(mock_venue)
    mock_venue.expects(:address).returns(mock_address)
    mock_address.expects(:geolocation).returns(mock_geolocation)
    get :show, params: { party_id: '37' }
    assert_equal mock_party, assigns(:party)
    assert_equal mock_venue, assigns(:venue)
    assert_equal mock_address, assigns(:address)
    assert_equal mock_geolocation, assigns(:geolocation)
  ensure
    @controller = old_controller
  end


  def test_expose_a_new_address_on_new
    Party.expects(:find).with('37').returns(mock_party)
    mock_party.expects(:venue).returns(mock_venue)
    mock_venue.expects(:build_address).returns(mock_address)
    get :new, params: { party_id: '37' }
    assert_equal mock_party, assigns(:party)
    assert_equal mock_venue, assigns(:venue)
    assert_equal mock_address, assigns(:address)
  end

  def test_expose_the_address_on_edit
    Party.expects(:find).with('37').returns(mock_party)
    mock_party.expects(:venue).returns(mock_venue)
    mock_venue.expects(:address).returns(mock_address)
    get :edit, params: { party_id: '37' }
    assert_equal mock_party, assigns(:party)
    assert_equal mock_venue, assigns(:venue)
    assert_equal mock_address, assigns(:address)
    assert_response :success
  end

  def test_expose_the_address_on_show
    Party.expects(:find).with('37').returns(mock_party)
    mock_party.expects(:venue).returns(mock_venue)
    mock_venue.expects(:address).returns(mock_address)
    get :show, params: { party_id: '37' }
    assert_equal mock_party, assigns(:party)
    assert_equal mock_venue, assigns(:venue)
    assert_equal mock_address, assigns(:address)
    assert_response :success
  end

  def test_expose_a_newly_create_address_on_create
    Party.expects(:find).with('37').returns(mock_party)
    mock_party.expects(:venue).returns(mock_venue)
    mock_venue.expects(:build_address).with({'these' => 'params'}).returns(mock_address(save: true))
    post :create, params: { party_id: '37', address: {these: 'params'} }
    assert_equal mock_party, assigns(:party)
    assert_equal mock_venue, assigns(:venue)
    assert_equal mock_address, assigns(:address)
  end

  def test_update_the_requested_object_on_update
    Party.expects(:find).with('37').returns(mock_party)
    mock_party.expects(:venue).returns(mock_venue(address: mock_address))
    mock_address.expects(:update_attributes).with({'these' => 'params'}).returns(mock_address(save: true))
    post :update, params: { party_id: '37', address: {these: 'params'} }
    assert_equal mock_party, assigns(:party)
    assert_equal mock_venue, assigns(:venue)
    assert_equal mock_address, assigns(:address)
  end

  def test_the_requested_manager_is_destroyed_on_destroy
    Party.expects(:find).with('37').returns(mock_party)
    mock_party.expects(:venue).returns(mock_venue)
    mock_venue.expects(:address).returns(mock_address)
    @controller.expects(:parent_url).returns('http://test.host/')
    mock_address.expects(:destroy)
    delete :destroy, params: { party_id: '37' }
    assert_equal mock_party, assigns(:party)
    assert_equal mock_venue, assigns(:venue)
    assert_equal mock_address, assigns(:address)
  end


  protected

    def mock_party(stubs={})
      @mock_party ||= mock('party',stubs)
    end

    def mock_venue(stubs={})
      @mock_venue ||= mock('venue',stubs)
    end

    def mock_address(stubs={})
      @mock_address ||= mock('address',stubs)
    end

    def mock_geolocation(stubs={})
      @mock_geolocation ||= mock('geolocation', stubs)
    end
end
