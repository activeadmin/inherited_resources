require File.dirname(__FILE__) + '/test_helper'

class Country
end

class State
end

class City
  def self.human_name; 'City'; end
end

class CitiesController < InheritedResources::Base
  belongs_to :country, :state
end

# Create a TestHelper module with some helpers
class NestedBelongsToTest < TEST_CLASS

  def setup
    @controller          = CitiesController.new
    @controller.request  = @request  = ActionController::TestRequest.new
    @controller.response = @response = ActionController::TestResponse.new
  end

  def test_assigns_country_and_state_and_city_on_create
    Country.expects(:find).with('13').returns(mock_country)
    mock_country.expects(:states).returns(State)
    State.expects(:find).with('37').returns(mock_state)
    mock_state.expects(:cities).returns(City)
    City.expects(:find).with(:all).returns([mock_city])

    get :index, :state_id => '37', :country_id => '13'

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal [mock_city], assigns(:cities)
  end

  def test_assigns_country_and_state_and_city_on_show
    Country.expects(:find).with('13').returns(mock_country)
    mock_country.expects(:states).returns(State)
    State.expects(:find).with('37').returns(mock_state)
    mock_state.expects(:cities).returns(City)
    City.expects(:find).with('42').returns(mock_city)

    get :show, :id => '42', :state_id => '37', :country_id => '13'

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end

  def test_assigns_country_and_state_and_city_on_new
    Country.expects(:find).with('13').returns(mock_country)
    mock_country.expects(:states).returns(State)
    State.expects(:find).with('37').returns(mock_state)
    mock_state.expects(:cities).returns(City)
    City.expects(:build).returns(mock_city)

    get :new, :state_id => '37', :country_id => '13'

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end

  def test_assigns_country_and_state_and_city_on_edit
    Country.expects(:find).with('13').returns(mock_country)
    mock_country.expects(:states).returns(State)
    State.expects(:find).with('37').returns(mock_state)
    mock_state.expects(:cities).returns(City)
    City.expects(:find).with('42').returns(mock_city)

    get :edit, :id => '42', :state_id => '37', :country_id => '13'

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end

  def test_assigns_country_and_state_and_city_on_create
    Country.expects(:find).with('13').returns(mock_country)
    mock_country.expects(:states).returns(State)
    State.expects(:find).with('37').returns(mock_state)
    mock_state.expects(:cities).returns(City)
    City.expects(:build).with({'these' => 'params'}).returns(mock_city(:save => true))

    post :create, :state_id => '37', :country_id => '13', :city => {:these => 'params'}

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end

  def test_assigns_country_and_state_and_city_on_update
    Country.expects(:find).with('13').returns(mock_country)
    mock_country.expects(:states).returns(State)
    State.expects(:find).with('37').returns(mock_state)
    mock_state.expects(:cities).returns(City)
    City.expects(:find).with('42').returns(mock_city)
    mock_city.expects(:update_attributes).with({'these' => 'params'}).returns(true)

    put :update, :id => '42', :state_id => '37', :country_id => '13', :city => {:these => 'params'}

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end
  
  def test_assigns_country_and_state_and_city_on_destroy
    Country.expects(:find).with('13').returns(mock_country)
    mock_country.expects(:states).returns(State)
    State.expects(:find).with('37').returns(mock_state)
    mock_state.expects(:cities).returns(City)
    City.expects(:find).with('42').returns(mock_city)
    mock_city.expects(:destroy)

    delete :destroy, :id => '42', :state_id => '37', :country_id => '13'

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end

  protected
    def mock_country(stubs={})
      @mock_country ||= mock(stubs)
    end

    def mock_state(stubs={})
      @mock_state ||= mock(stubs)
    end

    def mock_city(stubs={})
      @mock_city ||= mock(stubs)
    end
end
