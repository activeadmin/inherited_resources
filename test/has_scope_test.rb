require File.dirname(__FILE__) + '/test_helper'

class Tree
  def self.human_name; 'Tree'; end
end

class Branch
  def self.human_name; 'Branch'; end
end

class TreesController < InheritedResources::Base
  has_scope :color
  has_scope :only_tall, :boolean => true, :only => :index
  has_scope :shadown_range, :default => 10, :except => [ :index, :show, :destroy ]
  has_scope :root_type, :key => :root
  has_scope :another, :on => :anything, :default => 10, :only => :destroy
end

class BranchesController < InheritedResources::Base
  belongs_to :tree do
    load_scopes_from TreesController
  end
end

class HasScopeTest < ActionController::TestCase
  tests TreesController

  def setup
    @controller.stubs(:resource_url).returns('/')
    @controller.stubs(:collection_url).returns('/')
  end

  def test_boolean_scope_is_called_when_boolean_param_is_true
    Tree.expects(:only_tall).with().returns(Tree).in_sequence
    Tree.expects(:find).with(:all).returns([mock_tree]).in_sequence
    get :index, :only_tall => 'true'
    assert_equal([mock_tree], assigns(:trees))
    assert_equal({ :only_tall => 'true' }, assigns(:current_scopes))
  end

  def test_boolean_scope_is_called_when_boolean_param_is_false
    Tree.expects(:only_tall).never
    Tree.expects(:find).with(:all).returns([mock_tree])
    get :index, :only_tall => 'false'
    assert_equal([mock_tree], assigns(:trees))
    assert_equal({ :only_tall => 'false' }, assigns(:current_scopes))
  end

  def test_scope_is_called_only_on_index
    Tree.expects(:only_tall).never
    Tree.expects(:find).with('42').returns(mock_tree)
    get :show, :only_tall => 'true', :id => '42'
    assert_equal(mock_tree, assigns(:tree))
    assert_equal({ }, assigns(:current_scopes))
  end

  def test_scope_is_called_except_on_index
    Tree.expects(:shadown_range).with().never
    Tree.expects(:find).with(:all).returns([mock_tree])
    get :index, :shadown_range => 20
    assert_equal([mock_tree], assigns(:trees))
    assert_equal({ }, assigns(:current_scopes))
  end

  def test_scope_is_called_with_arguments
    Tree.expects(:color).with('blue').returns(Tree).in_sequence
    Tree.expects(:find).with(:all).returns([mock_tree]).in_sequence
    get :index, :color => 'blue'
    assert_equal([mock_tree], assigns(:trees))
    assert_equal({ :color => 'blue' }, assigns(:current_scopes))
  end

  def test_multiple_scopes_are_called
    Tree.expects(:only_tall).with().returns(Tree)
    Tree.expects(:color).with('blue').returns(Tree)
    Tree.expects(:find).with(:all).returns([mock_tree])
    get :index, :color => 'blue', :only_tall => 'true'
    assert_equal([mock_tree], assigns(:trees))
    assert_equal({ :color => 'blue', :only_tall => 'true' }, assigns(:current_scopes))
  end

  def test_scope_is_called_with_default_value
    Tree.expects(:shadown_range).with(10).returns(Tree).in_sequence
    Tree.expects(:find).with('42').returns(mock_tree).in_sequence
    get :edit, :id => '42'
    assert_equal(mock_tree, assigns(:tree))
    assert_equal({ :shadown_range => 10 }, assigns(:current_scopes))
  end

  def test_default_scope_value_can_be_overwritten
    Tree.expects(:shadown_range).with('20').returns(Tree).in_sequence
    Tree.expects(:find).with('42').returns(mock_tree).in_sequence
    get :edit, :id => '42', :shadown_range => '20'
    assert_equal(mock_tree, assigns(:tree))
    assert_equal({ :shadown_range => '20' }, assigns(:current_scopes))
  end

  def test_scope_with_different_key
    Tree.expects(:root_type).with('outside').returns(Tree).in_sequence
    Tree.expects(:find).with('42').returns(mock_tree).in_sequence
    get :show, :id => '42', :root => 'outside'
    assert_equal(mock_tree, assigns(:tree))
    assert_equal({ :root => 'outside' }, assigns(:current_scopes))
  end

  def test_scope_on_another_object_is_never_called
    Tree.expects(:another).never
    Tree.expects(:find).with('42').returns(mock_tree)
    mock_tree.expects(:destroy)
    delete :destroy, :id => '42'
    assert_equal(mock_tree, assigns(:tree))
    assert_equal({ }, assigns(:current_scopes))
  end

  protected

    def mock_tree(stubs={})
      @mock_tree ||= mock(stubs)
    end

end
