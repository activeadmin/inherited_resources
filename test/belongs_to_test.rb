# frozen_string_literal: true
require 'test_helper'

class Article
  extend ActiveModel::Naming
end

class Comment
  extend ActiveModel::Naming
end

class CommentsController < InheritedResources::Base
  belongs_to :article
end

class BelongsToTest < ActionController::TestCase
  tests CommentsController

  def setup
    draw_routes do
      resources :comments, :articles
    end

    Article.expects(:find).with('37').returns(mock_article)
    mock_article.expects(:comments).returns(Comment)
  end

  def teardown
    clear_routes
  end

  def test_parent_type_is_the_parent_model_name
    Comment.stubs(:scoped).returns([])
    mock_article.stubs(:class).returns(Article)
    get :index, params: { article_id: '37' }

    assert_equal :article, @controller.send(:parent_type)
  end

  def test_expose_all_comments_as_instance_variable_on_index
    Comment.expects(:scoped).returns([mock_comment])
    get :index, params: { article_id: '37' }

    assert_equal mock_article, assigns(:article)
    assert_equal [mock_comment], assigns(:comments)
  end

  def test_expose_the_requested_comment_on_show
    Comment.expects(:find).with('42').returns(mock_comment)
    get :show, params: { id: '42', article_id: '37' }

    assert_equal mock_article, assigns(:article)
    assert_equal mock_comment, assigns(:comment)
  end

  def test_expose_a_new_comment_on_new
    Comment.expects(:build).returns(mock_comment)
    get :new, params: { article_id: '37' }

    assert_equal mock_article, assigns(:article)
    assert_equal mock_comment, assigns(:comment)
  end

  def test_expose_the_requested_comment_on_edit
    Comment.expects(:find).with('42').returns(mock_comment)
    get :edit, params: { id: '42', article_id: '37' }

    assert_equal mock_article, assigns(:article)
    assert_equal mock_comment, assigns(:comment)
  end

  def test_expose_a_newly_create_comment_on_create
    Comment.expects(:build).with(build_parameters({'these' => 'params'})).returns(mock_comment(save: true))
    post :create, params: { article_id: '37', comment: {these: 'params'} }

    assert_equal mock_article, assigns(:article)
    assert_equal mock_comment, assigns(:comment)
  end

  def test_update_the_requested_object_on_update
    Comment.expects(:find).with('42').returns(mock_comment)
    mock_comment.expects(:update).with(build_parameters({'these' => 'params'})).returns(true)
    put :update, params: { id: '42', article_id: '37', comment: {these: 'params'} }

    assert_equal mock_article, assigns(:article)
    assert_equal mock_comment, assigns(:comment)
  end

  def test_the_requested_comment_is_destroyed_on_destroy
    Comment.expects(:find).with('42').returns(mock_comment)
    mock_comment.expects(:destroy)
    delete :destroy, params: { id: '42', article_id: '37' }

    assert_equal mock_article, assigns(:article)
    assert_equal mock_comment, assigns(:comment)
  end

  def helper_methods
    @controller.class._helpers.instance_methods.map {|m| m.to_s }
  end

  def test_helpers
    Comment.expects(:scoped).returns([mock_comment])
    get :index, params: { article_id: '37' }

    assert_includes helper_methods, 'parent?'
    assert @controller.send(:parent?)
    assert_equal mock_article, assigns(:article)
    assert_includes helper_methods, 'parent'
    assert_equal mock_article, @controller.send(:parent)
  end

  protected

    def mock_article(stubs={})
      @mock_article ||= mock(stubs)
    end

    def mock_comment(stubs={})
      @mock_comment ||= mock(stubs)
    end

    def build_parameters(hash)
      ActionController::Parameters.new(hash)
    end
end

class Reply
  extend ActiveModel::Naming
end

class RepliesController < InheritedResources::Base
  belongs_to :article
  actions :all, except: [:show, :index]
end

class BelongsToWithRedirectsTest < ActionController::TestCase
  tests RepliesController

  def setup
    draw_routes do
      resources :replies, :articles
    end

    Article.expects(:find).with('37').returns(mock_article)
    mock_article.expects(:replies).returns(Reply)
  end

  def teardown
    clear_routes
  end

  def test_redirect_to_the_article_on_create_if_show_and_index_undefined
    @controller.expects(:parent_url).returns('http://test.host/')
    Reply.expects(:build).with(build_parameters({'these' => 'params'})).returns(mock_reply(save: true))
    post :create, params: { article_id: '37', reply: { these: 'params' } }

    assert_redirected_to 'http://test.host/'
  end

  def test_redirect_to_the_article_on_update_if_show_and_index_undefined
    Reply.stubs(:find).returns(mock_reply(update: true))
    @controller.expects(:parent_url).returns('http://test.host/')
    put :update, params: { id: '42', article_id: '37', reply: { these: 'params' } }

    assert_redirected_to 'http://test.host/'
  end

  def test_redirect_to_the_article_on_destroy_if_show_and_index_undefined
    Reply.expects(:find).with('42').returns(mock_reply)
    mock_reply.expects(:destroy)
    @controller.expects(:parent_url).returns('http://test.host/')
    delete :destroy, params: { id: '42', article_id: '37' }

    assert_redirected_to 'http://test.host/'
  end

  protected

    def mock_article(stubs={})
      @mock_article ||= mock(stubs)
    end

    def mock_reply(stubs={})
      @mock_reply ||= mock(stubs)
    end

    def build_parameters(hash)
      ActionController::Parameters.new(hash)
    end
end

class SingletonParentTest < ActiveSupport::TestCase
  def test_singleton_parent_is_fetched_from_the_beginning_of_the_chain
    user = mock
    office = mock
    user.expects(:office).returns(office)
    controller = build_reports_controller { define_method(:begin_of_association_chain) { user } }.new

    assert_equal [user, office], controller.send(:association_chain)
    assert_same office, controller.send(:parent)
  end

  # Singleton parents are reached through the object before them; they're never
  # looked up by id, so there's nothing to fetch without a chain.
  def test_singleton_parent_is_nil_without_anything_before_it_in_the_chain
    controller = build_reports_controller.new
    controller.params = ActionController::Parameters.new(office_id: '1')

    assert_empty controller.send(:association_chain)
    assert_nil controller.send(:parent)
  end

  private

    def build_reports_controller(&body)
      build_controller('ReportsController') do
        belongs_to :office, singleton: true, parent_class: Class.new
        class_eval(&body) if body
      end
    end
end
