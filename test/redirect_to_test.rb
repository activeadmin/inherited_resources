require 'test_helper'

class Machine;
  def self.human_name; 'Machine'; end
end

class MachinesController < InheritedResources::Base
  def create
    create!{ complex_url(:create, true, true) }
  end

  def update
    update!{ complex_url(:update, false, false) }
  end

  def destroy
    destroy!{ complex_url(:destroy, true, false) }
  end

  protected

    def complex_url(name, arg2, arg3)
      'http://test.host/' + name.to_s
    end
end

class RedirectToWithBlockTest < ActionController::TestCase
  tests MachinesController

  def setup
    draw_routes do
      resources :machines
    end
  end

  def teardown
    clear_routes
  end

  def test_redirect_to_the_given_url_on_create
    Machine.stubs(:new).returns(mock_machine(save: true))
    post :create
    assert_redirected_to 'http://test.host/create'
  end

  def test_redirect_to_the_given_url_on_update
    Machine.stubs(:find).returns(mock_machine(update: true))
    put :update, params: { id: '42' }
    assert_redirected_to 'http://test.host/update'
  end

  def test_redirect_to_the_given_url_on_destroy
    Machine.stubs(:find).returns(mock_machine(destroy: true))
    delete :destroy, params: { id: '42' }
    assert_redirected_to 'http://test.host/destroy'
  end

  protected

    def mock_machine(stubs={})
      @mock_machine ||= mock(stubs)
    end
end
