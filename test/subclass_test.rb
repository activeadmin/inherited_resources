require File.expand_path('test_helper', File.dirname(__FILE__))

class Cheese
end
class Livarot
end
class CheesesController < InheritedResources::Base
end
class LivarotsController < CheesesController
end
class SubclassedResourceController < ActionController::TestCase
  tests LivarotsController

  def test_that_it_picked_the_subclass_model
    # make public so we can test it
    LivarotsController.send(:public, *LivarotsController.protected_instance_methods)
    assert_equal Livarot, @controller.resource_class
  end
end