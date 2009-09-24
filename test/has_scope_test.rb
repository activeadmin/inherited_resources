require File.dirname(__FILE__) + '/test_helper'

class Tree
  def self.human_name; 'Tree'; end
end

class TreesController < InheritedResources::Base
  has_scope :color, :unless => :show_all_colors?
  has_scope :only_tall, :boolean => true, :only => :index, :if => :restrict_to_only_tall_trees?
  has_scope :shadown_range, :default => 10, :except => [ :index, :show, :destroy, :new ]
  has_scope :root_type, :as => :root
  has_scope :calculate_height, :default => proc {|c| c.session[:height] || 20 }, :only => :new

  protected
    def restrict_to_only_tall_trees?
      true
    end

    def show_all_colors?
      false
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

  def test_scope_is_skipped_when_if_option_is_false
    @controller.stubs(:restrict_to_only_tall_trees?).returns(false)
    Tree.expects(:only_tall).never
    Tree.expects(:find).with(:all).returns([mock_tree])
    get :index, :only_tall => 'true'
    assert_equal([mock_tree], assigns(:trees))
    assert_equal({ }, assigns(:current_scopes))
  end

  def test_scope_is_skipped_when_unless_option_is_true
    @controller.stubs(:show_all_colors?).returns(true)
    Tree.expects(:color).never
    Tree.expects(:find).with(:all).returns([mock_tree])
    get :index, :color => 'blue'
    assert_equal([mock_tree], assigns(:trees))
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

  def test_scope_with_default_value_as_proc
    session[:height] = 100
    Tree.expects(:calculate_height).with(100).returns(Tree).in_sequence
    Tree.expects(:new).returns(mock_tree).in_sequence
    get :new
    assert_equal(mock_tree, assigns(:tree))
    assert_equal({ :calculate_height => 100 }, assigns(:current_scopes))
   end

  protected

    def mock_tree(stubs={})
      @mock_tree ||= mock(stubs)
    end

end

