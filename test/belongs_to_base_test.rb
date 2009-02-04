require File.dirname(__FILE__) + '/test_helper'

# This test file is instead to test the how controller flow and actions
# using a belongs_to association. This is done using mocks a la rspec.
#
class Post
end

class Comment
  def self.human_name; 'Comment'; end
end

class CommentsController < InheritedResources::Base
  belongs_to :post
end

# Create a TestHelper module with some helpers
module CommentTestHelper
  def setup
    @controller          = CommentsController.new
    @controller.request  = @request  = ActionController::TestRequest.new
    @controller.response = @response = ActionController::TestResponse.new
  end

  protected
    def mock_post(stubs={})
      @mock_post ||= mock(stubs)
    end

    def mock_comment(stubs={})
      @mock_comment ||= mock(stubs)
    end
end

class IndexActionBelongsToTest < Test::Unit::TestCase
  include CommentTestHelper

  def test_expose_all_comments_as_instance_variable
    Post.expects(:find).with('37').returns(mock_post)
    mock_post.expects(:comments).returns(Comment)
    Comment.expects(:find).with(:all).returns([mock_comment])
    get :index, :post_id => '37'
    assert_equal mock_post, assigns(:post)
    assert_equal [mock_comment], assigns(:comments)
  end

  def test_controller_should_render_index
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:find).returns([mock_comment])
    get :index
    assert_response :success
    assert_equal 'Index HTML', @response.body.strip
  end

  def test_render_all_comments_as_xml_when_mime_type_is_xml
    @request.accept = 'application/xml'
    Post.expects(:find).with('37').returns(mock_post)
    mock_post.expects(:comments).returns(Comment)
    Comment.expects(:find).with(:all).returns(mock_comment)
    mock_comment.expects(:to_xml).returns('Generated XML')
    get :index, :post_id => '37'
    assert_response :success
    assert_equal 'Generated XML', @response.body
  end
end

class ShowActionBelongsToTest < Test::Unit::TestCase
  include CommentTestHelper

  def test_expose_the_resquested_comment
    Post.expects(:find).with('37').returns(mock_post)
    mock_post.expects(:comments).returns(Comment)
    Comment.expects(:find).with('42').returns(mock_comment)
    get :show, :id => '42', :post_id => '37'
    assert_equal mock_post, assigns(:post)
    assert_equal mock_comment, assigns(:comment)
  end

  def test_controller_should_render_show
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:find).returns(mock_comment)
    get :show
    assert_response :success
    assert_equal 'Show HTML', @response.body.strip
  end

  def test_render_exposed_comment_as_xml_when_mime_type_is_xml
    @request.accept = 'application/xml'
    Post.expects(:find).with('37').returns(mock_post)
    mock_post.expects(:comments).returns(Comment)
    Comment.expects(:find).with('42').returns(mock_comment)
    mock_comment.expects(:to_xml).returns("Generated XML")
    get :show, :id => '42', :post_id => '37'
    assert_response :success
    assert_equal 'Generated XML', @response.body
  end
end

class NewActionBelongsToTest < Test::Unit::TestCase
  include CommentTestHelper

  def test_expose_a_new_comment
    Post.expects(:find).with('37').returns(mock_post)
    mock_post.expects(:comments).returns(Comment)
    Comment.expects(:build).returns(mock_comment)
    get :new, :post_id => '37'
    assert_equal mock_post, assigns(:post)
    assert_equal mock_comment, assigns(:comment)
  end

  def test_controller_should_render_new
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:build).returns(mock_comment)
    get :new
    assert_response :success
    assert_equal 'New HTML', @response.body.strip
  end

  def test_render_exposed_a_new_comment_as_xml_when_mime_type_is_xml
    @request.accept = 'application/xml'
    Post.expects(:find).with('37').returns(mock_post)
    mock_post.expects(:comments).returns(Comment)
    Comment.expects(:build).returns(mock_comment)
    mock_comment.expects(:to_xml).returns("Generated XML")
    get :new, :post_id => '37'
    assert_equal 'Generated XML', @response.body
    assert_response :success
  end
end

class EditActionBelongsToTest < Test::Unit::TestCase
  include CommentTestHelper

  def test_expose_the_resquested_comment
    Post.expects(:find).with('37').returns(mock_post)
    mock_post.expects(:comments).returns(Comment)
    Comment.expects(:find).with('42').returns(mock_comment)
    get :edit, :id => '42', :post_id => '37'
    assert_equal mock_post, assigns(:post)
    assert_equal mock_comment, assigns(:comment)
    assert_response :success
  end

  def test_controller_should_render_edit
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:find).returns(mock_comment)
    get :edit
    assert_response :success
    assert_equal 'Edit HTML', @response.body.strip
  end
end

class CreateActionBelongsToTest < Test::Unit::TestCase
  include CommentTestHelper

  def test_expose_a_newly_create_comment_when_saved_with_success
    Post.expects(:find).with('37').returns(mock_post)
    mock_post.expects(:comments).returns(Comment)
    Comment.expects(:build).with({'these' => 'params'}).returns(mock_comment(:save => true))
    post :create, :post_id => '37', :comment => {:these => 'params'}
    assert_equal mock_post, assigns(:post)
    assert_equal mock_comment, assigns(:comment)
  end

  def test_redirect_to_the_created_comment
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:build).returns(mock_comment(:save => true))
    @controller.expects(:resource_url).returns('http://test.host/').times(2)
    post :create
    assert_redirected_to 'http://test.host/'
  end

  def test_show_flash_message_when_success
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:build).returns(mock_comment(:save => true))
    post :create
    assert_equal flash[:notice], 'Comment was successfully created.'
  end

  def test_render_new_template_when_comment_cannot_be_saved
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:build).returns(mock_comment(:save => false, :errors => []))
    post :create
    assert_response :success
    assert_template 'new'
  end

  def test_dont_show_flash_message_when_comment_cannot_be_saved
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:build).returns(mock_comment(:save => false, :errors => []))
    post :create
    assert flash.empty?
  end
end

class UpdateActionBelongsToTest < Test::Unit::TestCase
  include CommentTestHelper

  def test_update_the_requested_object
    Post.expects(:find).with('37').returns(mock_post)
    mock_post.expects(:comments).returns(Comment)
    Comment.expects(:find).with('42').returns(mock_comment)
    mock_comment.expects(:update_attributes).with({'these' => 'params'}).returns(true)
    put :update, :id => '42', :post_id => '37', :comment => {:these => 'params'}
    assert_equal mock_post, assigns(:post)
    assert_equal mock_comment, assigns(:comment)
  end

  def test_redirect_to_the_created_comment
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:find).returns(mock_comment(:update_attributes => true))
    @controller.expects(:resource_url).returns('http://test.host/')
    put :update
    assert_redirected_to 'http://test.host/'
  end

  def test_show_flash_message_when_success
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:find).returns(mock_comment(:update_attributes => true))
    put :update
    assert_equal flash[:notice], 'Comment was successfully updated.'
  end

  def test_render_edit_template_when_comment_cannot_be_saved
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:find).returns(mock_comment(:update_attributes => false, :errors => []))
    put :update
    assert_response :success
    assert_template 'edit'
  end

  def test_dont_show_flash_message_when_comment_cannot_be_saved
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:find).returns(mock_comment(:update_attributes => false, :errors => []))
    put :update
    assert flash.empty?
  end
end

class DestroyActionBelongsToTest < Test::Unit::TestCase
  include CommentTestHelper
  
  def test_the_resquested_comment_is_destroyed
    Post.expects(:find).with('37').returns(mock_post)
    mock_post.expects(:comments).returns(Comment)
    Comment.expects(:find).with('42').returns(mock_comment)
    mock_comment.expects(:destroy)
    delete :destroy, :id => '42', :post_id => '37'
    assert_equal mock_post, assigns(:post)
    assert_equal mock_comment, assigns(:comment)
  end

  def test_show_flash_message
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:find).returns(mock_comment(:destroy => true))
    delete :destroy
    assert_equal flash[:notice], 'Comment was successfully destroyed.'
  end

  def test_redirects_to_comments_list
    Post.stubs(:find).returns(mock_post(:comments => Comment))
    Comment.stubs(:find).returns(mock_comment(:destroy => true))
    @controller.expects(:collection_url).returns('http://test.host/')
    delete :destroy
    assert_redirected_to 'http://test.host/'
  end
end

