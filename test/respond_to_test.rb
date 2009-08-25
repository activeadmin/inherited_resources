require File.dirname(__FILE__) + '/test_helper'

class Project
  def to_html
    'Generated HTML'
  end

  def to_xml
    'Generated XML'
  end

  [:to_json, :to_rss, :to_rjs].each do |method|
    undef_method method if respond_to? method
  end
end

class ProjectsController < ActionController::Base
  respond_to :html
  respond_to :xml,  :except => :edit
  respond_to :rjs,  :only => :edit
  respond_to :rss,  :only => :index
  respond_to :json, :except => :index
  respond_to :csv,  :except => :index

  def index
    respond_with(Project.new)
  end

  def respond_with_resource
    respond_with(Project.new)
  end

  def respond_with_resource_and_options
    respond_with(Project.new, :location => 'http://test.host/')
  end

  def respond_with_resource_and_blocks
    respond_with(Project.new) do |format|
      format.json { render :text => 'Render JSON' }
      format.rss  { render :text => 'Render RSS' }
    end
  end

  # If the user request Mime::ALL and we have a template called action.html.erb,
  # the html template should be rendered *unless* html is specified inside the
  # block. This tests exactly this case.
  #
  def respond_to_skip_default_template
    respond_with(Project.new) do |format|
      format.html { render :text => 'Render HTML' }
    end
  end
end

class SuperProjectsController < ProjectsController
end

class RespondToFunctionalTest < ActionController::TestCase
  tests ProjectsController

  def test_respond_with_layout_rendering
    @request.accept = 'text/html'
    get :index
    assert_equal 'Index HTML', @response.body.strip
  end

  def test_respond_with_calls_to_format_on_resource
    @request.accept = 'application/xml'
    get :index
    assert_equal 'Generated XML', @response.body.strip
  end

  def test_respond_with_inherits_format
    @request.accept = 'application/xml'
    get :index
    assert_equal 'Generated XML', @response.body.strip
  end

  def test_respond_with_renders_status_not_acceptable_if_mime_type_is_not_registered
    @request.accept = 'text/csv'
    get :index
    assert_equal '406 Not Acceptable', @response.status
  end

  def test_respond_with_raises_error_if_could_not_respond
    @request.accept = 'application/rss+xml'
    assert_raise ActionView::MissingTemplate do
      get :index
    end
  end

  def test_respond_to_all
    @request.accept = '*/*'
    get :index
    assert_equal 'Index HTML', @response.body.strip
  end

  def test_respond_with_sets_content_type_properly
    @request.accept = 'text/html'
    get :index
    assert_equal 'text/html', @response.content_type
    assert_equal :html, @response.template.template_format

    @request.accept = 'application/xml'
    get :index
    assert_equal 'application/xml', @response.content_type
    assert_equal :xml, @response.template.template_format
  end

  def test_respond_with_forwads_extra_options_to_render
    @request.accept = 'application/xml'
    get :respond_with_resource_and_options
    assert_equal 'Generated XML', @response.body.strip
    assert_equal 'http://test.host/', @response.headers['Location']
  end

  def test_respond_to_when_a_resource_is_given_as_option
    @request.accept = 'text/html'
    get :respond_with_resource
    assert_equal 'RespondTo HTML', @response.body.strip

    @request.accept = 'application/xml'
    get :respond_with_resource
    assert_equal 'Generated XML', @response.body.strip

    @request.accept = 'application/rss+xml'
    get :respond_with_resource
    assert_equal '406 Not Acceptable', @response.status

    @request.accept = 'application/json'
    assert_raise ActionView::MissingTemplate do
      get :respond_with_resource
    end
  end

  def test_respond_to_overwrite_class_method_definition
    @request.accept = 'application/rss+xml'
    get :respond_with_resource_and_blocks
    assert_equal 'Render RSS', @response.body.strip
  end

  def test_respond_to_first_configured_mime_in_respond_to_when_mime_type_is_all
    @request.accept = '*/*'
    assert_raise ActionView::MissingTemplate do
      get :respond_with_resource_and_blocks
    end
    assert_equal 'text/html', @response.content_type
  end

  def test_respond_to_skip_default_template_when_it_is_in_block
    @request.accept = '*/*'
    get :respond_to_skip_default_template
    assert_equal 'Render HTML', @response.body.strip
  end
end
