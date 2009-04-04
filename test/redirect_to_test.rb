require File.dirname(__FILE__) + '/test_helper'

class Machine;
  def self.human_name; 'Machine'; end
end

class MachinesController < InheritedResources::Base

  def create
    create!('http://test.host/')
  end

  def update
    update!('http://test.host/')
  end

  def destroy
    destroy!('http://test.host/')
  end

end

class RedirectToTest < ActionController::TestCase
  tests MachinesController

  def test_redirect_to_the_given_url_on_create
    Machine.stubs(:new).returns(mock_machine(:save => true))
    @controller.expects(:resource_url).times(0)
    post :create
    assert_redirected_to 'http://test.host/'
  end

  def test_redirect_to_the_given_url_on_update
    Machine.stubs(:find).returns(mock_machine(:update_attributes => true))
    @controller.expects(:resource_url).times(0)
    put :update
    assert_redirected_to 'http://test.host/'
  end

  def test_redirect_to_the_given_url_on_destroy
    Machine.stubs(:find).returns(mock_machine(:destroy => true))
    @controller.expects(:collection_url).times(0)
    put :destroy
    assert_redirected_to 'http://test.host/'
  end

  protected
    def mock_machine(stubs={})
      @mock_machine ||= mock(stubs)
    end
end

