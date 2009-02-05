require File.dirname(__FILE__) + '/test_helper'

class Book; end
class Folder; end

class BooksController < InheritedResources::Base
  actions :index, :show
end

class ReadersController < InheritedResources::Base
  actions :all, :except => [ :edit, :update ]
end

class FoldersController < InheritedResources::Base
end

class ActionsTest < ActiveSupport::TestCase
  def test_actions_are_undefined_when_only_option_is_given
    action_methods = BooksController.send(:action_methods)
    assert_equal 2, action_methods.size

    ['index', 'show'].each do |action|
      assert action_methods.include? action
    end
  end

  def test_actions_are_undefined_when_except_option_is_given
    action_methods = ReadersController.send(:action_methods)
    assert_equal 5, action_methods.size

    ['index', 'new', 'show', 'create', 'destroy'].each do |action|
      assert action_methods.include? action
    end
  end
end

class DefaultsTest < ActiveSupport::TestCase
  def test_resource_class_is_set_to_nil_when_resource_model_cannot_be_found
    assert_nil ReadersController.send(:resource_class)
  end

  def test_defaults_are_set
    assert Folder, FoldersController.send(:resource_class)
    assert :folder, FoldersController.send(:resources_configuration)[:self][:instance_name]
    assert :folders, FoldersController.send(:resources_configuration)[:self][:collection_name]
  end

  def test_defaults_can_be_overwriten
    BooksController.send(:defaults, :resource_class => String, :instance_name => 'string', :collection_name => 'strings')

    assert String, BooksController.send(:resource_class)
    assert :string, BooksController.send(:resources_configuration)[:self][:instance_name]
    assert :strings, BooksController.send(:resources_configuration)[:self][:collection_name]

    BooksController.send(:defaults, :class_name => 'Fixnum', :instance_name => :fixnum, :collection_name => :fixnums)

    assert String, BooksController.send(:resource_class)
    assert :string, BooksController.send(:resources_configuration)[:self][:instance_name]
    assert :strings, BooksController.send(:resources_configuration)[:self][:collection_name]
  end

  def test_defaults_raises_invalid_key
    assert_raise ArgumentError do
      BooksController.send(:defaults, :boom => String)
    end
  end

  def test_url_helpers_are_recreated_when_defaults_change
    InheritedResources::UrlHelpers.expects(:create_resources_url_helpers!).returns(true).once
    BooksController.send(:defaults, :instance_name => 'string', :collection_name => 'strings')
  end

end
