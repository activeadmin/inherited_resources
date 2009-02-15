require File.dirname(__FILE__) + '/test_helper'

class Brands; end
class Category; end

class Product
  def self.human_name; 'Product'; end
end

class ProductsController < InheritedResources::Base
  belongs_to :brand, :category, :polymorphic => true, :optional => true
end

# Create a TestHelper module with some helpers
module ProductTestHelper
  def setup
    @controller          = ProductsController.new
    @controller.request  = @request  = ActionController::TestRequest.new
    @controller.response = @response = ActionController::TestResponse.new
  end

  protected
    def mock_category(stubs={})
      @mock_category ||= mock(stubs)
    end

    def mock_product(stubs={})
      @mock_product ||= mock(stubs)
    end
end

class IndexActionOptionalTest < TEST_CLASS
  include ProductTestHelper

  def test_expose_all_products_as_instance_variable_with_category
    Category.expects(:find).with('37').returns(mock_category)
    mock_category.expects(:products).returns(Product)
    Product.expects(:find).with(:all).returns([mock_product])
    get :index, :category_id => '37'
    assert_equal mock_category, assigns(:category)
    assert_equal [mock_product], assigns(:products)
  end

  def test_expose_all_products_as_instance_variable_without_category
    Product.expects(:find).with(:all).returns([mock_product])
    get :index
    assert_equal nil, assigns(:category)
    assert_equal [mock_product], assigns(:products)
  end
end

class ShowActionOptionalTest < TEST_CLASS
  include ProductTestHelper

  def test_expose_the_resquested_product_with_category
    Category.expects(:find).with('37').returns(mock_category)
    mock_category.expects(:products).returns(Product)
    Product.expects(:find).with('42').returns(mock_product)
    get :show, :id => '42', :category_id => '37'
    assert_equal mock_category, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end

  def test_expose_the_resquested_product_without_category
    Product.expects(:find).with('42').returns(mock_product)
    get :show, :id => '42'
    assert_equal nil, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end
end

class NewActionOptionalTest < TEST_CLASS
  include ProductTestHelper

  def test_expose_a_new_product_with_category
    Category.expects(:find).with('37').returns(mock_category)
    mock_category.expects(:products).returns(Product)
    Product.expects(:build).returns(mock_product)
    get :new, :category_id => '37'
    assert_equal mock_category, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end

  def test_expose_a_new_product_without_category
    Product.expects(:new).returns(mock_product)
    get :new
    assert_equal nil, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end
end

class EditActionOptionalTest < TEST_CLASS
  include ProductTestHelper

  def test_expose_the_resquested_product_with_category
    Category.expects(:find).with('37').returns(mock_category)
    mock_category.expects(:products).returns(Product)
    Product.expects(:find).with('42').returns(mock_product)
    get :edit, :id => '42', :category_id => '37'
    assert_equal mock_category, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end

  def test_expose_the_resquested_product_without_category
    Product.expects(:find).with('42').returns(mock_product)
    get :edit, :id => '42'
    assert_equal nil, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end
end

class CreateActionOptionalTest < TEST_CLASS
  include ProductTestHelper

  def test_expose_a_newly_create_product_with_category
    Category.expects(:find).with('37').returns(mock_category)
    mock_category.expects(:products).returns(Product)
    Product.expects(:build).with({'these' => 'params'}).returns(mock_product(:save => true))
    post :create, :category_id => '37', :product => {:these => 'params'}
    assert_equal mock_category, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end

  def test_expose_a_newly_create_product_without_category
    Product.expects(:new).with({'these' => 'params'}).returns(mock_product(:save => true))
    post :create, :product => {:these => 'params'}
    assert_equal nil, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end
end

class UpdateActionOptionalTest < TEST_CLASS
  include ProductTestHelper

  def test_update_the_requested_object_with_category
    Category.expects(:find).with('37').returns(mock_category)
    mock_category.expects(:products).returns(Product)
    Product.expects(:find).with('42').returns(mock_product)
    mock_product.expects(:update_attributes).with({'these' => 'params'}).returns(true)
    put :update, :id => '42', :category_id => '37', :product => {:these => 'params'}
    assert_equal mock_category, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end

  def test_update_the_requested_object_without_category
    Product.expects(:find).with('42').returns(mock_product)
    mock_product.expects(:update_attributes).with({'these' => 'params'}).returns(true)
    put :update, :id => '42', :product => {:these => 'params'}
    assert_equal nil, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end
end

class DestroyActionOptionalTest < TEST_CLASS
  include ProductTestHelper

  def test_the_resquested_product_is_destroyed_with_category
    Category.expects(:find).with('37').returns(mock_category)
    mock_category.expects(:products).returns(Product)
    Product.expects(:find).with('42').returns(mock_product)
    mock_product.expects(:destroy)
    delete :destroy, :id => '42', :category_id => '37'
    assert_equal mock_category, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end

  def test_the_resquested_product_is_destroyed_without_category
    Product.expects(:find).with('42').returns(mock_product)
    mock_product.expects(:destroy)
    delete :destroy, :id => '42'
    assert_equal nil, assigns(:category)
    assert_equal mock_product, assigns(:product)
  end
end

class OptionalHelpersTest < TEST_CLASS
  include ProductTestHelper

  def test_polymorphic_helpers
    Product.expects(:find).with(:all).returns([mock_product])
    get :index

    assert !@controller.send(:parent?)
    assert_equal nil, assigns(:parent_type)
    assert_equal nil, @controller.send(:parent_type)
    assert_equal nil, @controller.send(:parent_class)
    assert_equal nil, assigns(:category)
    assert_equal nil, @controller.send(:parent)
  end
end
