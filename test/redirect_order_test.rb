require File.expand_path('test_helper', File.dirname(__FILE__))

class Phone
  extend ActiveModel::Naming
end

class Charger
  extend ActiveModel::Naming
end

class ChargersController < InheritedResources::Base
  belongs_to :phone
  redirect_order [:root], :only => :create
  redirect_order [:collection, :root], :only => :update
  redirect_order [:parent, :root], :except => [:update, :create]
end

class RedirectAccordingToOrderTest < ActionController::TestCase
  tests ChargersController

  def setup
    phone = mock
    Phone.stubs(:find).returns(phone)
    phone.stubs(:chargers).returns(Charger)
    Charger.stubs(:save).returns(true)
    Charger.stubs(:find).returns(Charger)
  end

  def test_redirect_root_after_create
    Charger.stubs(:build).returns(Charger)
    post :create, :phone_id => '13'
    assert_redirected_to 'http://test.host/'
  end

  def test_redirect_collection_after_update
    test_url = "http://test.host/phones/13/chargers"
    Charger.stubs(:update_attributes).returns(true)
    @controller.expects(:phone_chargers_url).returns(test_url)
    put :update, :phone_id => '13'
    assert_redirected_to test_url
  end

  def test_redirect_parent_after_destroy
    test_url = "http://test.host/phones/13"
    Charger.stubs(:destroy).returns(true)
    @controller.expects(:phone_url).returns(test_url)
    delete :destroy, :phone_id => '13'
    assert_redirected_to test_url
  end
end
