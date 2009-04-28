require File.dirname(__FILE__) + '/test_helper'

class SuperMachine;
  def self.human_name; 'Machine'; end
end

# Use this to test blocks with multiple arity in the future.
class SuperMachinesController < InheritedResources::Base
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

class RedirectToWithArgumentTest < ActionController::TestCase
  tests SuperMachinesController

  def test_redirect_to_the_given_url_on_create
    ActiveSupport::Deprecation.expects(:warn).with('create!(redirect_url) is deprecated. Use create!{ redirect_url } instead.', [nil])
    SuperMachine.stubs(:new).returns(mock_machine(:save => true))
    @controller.expects(:resource_url).times(0)
    post :create
    assert_redirected_to 'http://test.host/'
  end

  def test_redirect_to_the_given_url_on_update
    ActiveSupport::Deprecation.expects(:warn).with('update!(redirect_url) is deprecated. Use update!{ redirect_url } instead.', [nil])
    SuperMachine.stubs(:find).returns(mock_machine(:update_attributes => true))
    @controller.expects(:resource_url).times(0)
    put :update
    assert_redirected_to 'http://test.host/'
  end

  def test_redirect_to_the_given_url_on_destroy
    ActiveSupport::Deprecation.expects(:warn).with('destroy!(redirect_url) is deprecated. Use destroy!{ redirect_url } instead.', [nil])
    SuperMachine.stubs(:find).returns(mock_machine(:destroy => true))
    @controller.expects(:collection_url).times(0)
    delete :destroy
    assert_redirected_to 'http://test.host/'
  end

  protected
    def mock_machine(stubs={})
      @mock_machine ||= mock(stubs)
    end
end

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

  def test_redirect_to_the_given_url_on_create
    Machine.stubs(:new).returns(mock_machine(:save => true))
    @controller.expects(:resource_url).times(0)
    post :create
    assert_redirected_to 'http://test.host/create'
  end

  def test_redirect_to_the_given_url_on_update
    Machine.stubs(:find).returns(mock_machine(:update_attributes => true))
    @controller.expects(:resource_url).times(0)
    put :update
    assert_redirected_to 'http://test.host/update'
  end

  def test_redirect_to_the_given_url_on_destroy
    Machine.stubs(:find).returns(mock_machine(:destroy => true))
    @controller.expects(:collection_url).times(0)
    delete :destroy
    assert_redirected_to 'http://test.host/destroy'
  end

  protected
    def mock_machine(stubs={})
      @mock_machine ||= mock(stubs)
    end
end

