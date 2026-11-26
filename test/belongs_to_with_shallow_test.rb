# frozen_string_literal: true
require 'test_helper'

class Blog
  extend ActiveModel::Naming
end

class Tag
  extend ActiveModel::Naming
end

class TagsController < InheritedResources::Base
  belongs_to :blog, shallow: true, finder: :find_by_slug
end

class BelongsToWithShallowTest < ActionController::TestCase
  tests TagsController

  def setup
    draw_routes do
      resources :tags
    end

    Blog.expects(:find_by_slug).with('thirty_seven').returns(mock_blog)
    mock_blog.expects(:tags).returns(Tag)

    @controller.stubs(:collection_url).returns('/')
  end

  def teardown
    clear_routes
  end

  def test_expose_all_tags_as_instance_variable_on_index
    Tag.expects(:scoped).returns([mock_tag])
    get :index, params: { blog_id: 'thirty_seven' }

    assert_equal mock_blog, assigns(:blog)
    assert_equal [mock_tag], assigns(:tags)
  end

  def test_expose_a_new_tag_on_new
    Tag.expects(:build).returns(mock_tag)
    get :new, params: { blog_id: 'thirty_seven' }

    assert_equal mock_blog, assigns(:blog)
    assert_equal mock_tag, assigns(:tag)
  end

  def test_expose_a_newly_create_tag_on_create
    Tag.expects(:build).with(build_parameters({'these' => 'params'})).returns(mock_tag(save: true))
    post :create, params: { blog_id: 'thirty_seven', tag: {these: 'params'} }

    assert_equal mock_blog, assigns(:blog)
    assert_equal mock_tag, assigns(:tag)
  end

  def test_expose_the_requested_tag_on_show
    should_find_parents
    get :show, params: { id: '42' }

    assert_equal mock_blog, assigns(:blog)
    assert_equal mock_tag, assigns(:tag)
  end

  def test_expose_the_requested_tag_on_edit
    should_find_parents
    get :edit, params: { id: '42' }

    assert_equal mock_blog, assigns(:blog)
    assert_equal mock_tag, assigns(:tag)
  end

  def test_update_the_requested_object_on_update
    should_find_parents
    mock_tag.expects(:update).with(build_parameters({'these' => 'params'})).returns(true)
    put :update, params: { id: '42', tag: {these: 'params'} }

    assert_equal mock_blog, assigns(:blog)
    assert_equal mock_tag, assigns(:tag)
  end

  def test_the_requested_tag_is_destroyed_on_destroy
    should_find_parents
    mock_tag.expects(:destroy)
    delete :destroy, params: { id: '42', blog_id: '37' }

    assert_equal mock_blog, assigns(:blog)
    assert_equal mock_tag, assigns(:tag)
  end

  protected

    def should_find_parents
      mock_tag.expects(:blog).returns(mock_blog)
      mock_blog.expects(:to_param).returns('thirty_seven')
      Tag.expects(:find).with('42').twice.returns(mock_tag)
    end

    def mock_blog(stubs={})
      @mock_blog ||= mock(stubs)
    end

    def mock_tag(stubs={})
      @mock_tag ||= mock(stubs)
    end

    def build_parameters(hash)
      ActionController::Parameters.new(hash)
    end
end
