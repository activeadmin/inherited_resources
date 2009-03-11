require File.dirname(__FILE__) + '/test_helper'

class Universe; end
class UniversesController < InheritedResources::Base
  defaults :singleton => true # Let's not discuss about this :P
end

class House; end
class HousesController < InheritedResources::Base
end

class Backpack; end
module Admin; end
class Admin::BackpacksController < InheritedResources::Base
end

class Table; end
class TablesController < InheritedResources::Base
  belongs_to :house
end

class RoomsController < InheritedResources::Base
  belongs_to :house, :route_name => 'big_house'
end

class ChairsController < InheritedResources::Base
  belongs_to :house do
    belongs_to :table
  end
end

class OwnersController < InheritedResources::Base
  belongs_to :house, :singleton => true
end

class Bed; end
class BedsController < InheritedResources::Base
  belongs_to :house, :building, :polymorphic => true, :optional => true
end

class Dish; end
class DishesController < InheritedResources::Base
  belongs_to :house do
    belongs_to :table, :kitchen, :polymorphic => true
  end
end

class Center; end
class CentersController < InheritedResources::Base
  acts_as_singleton!

  belongs_to :house do
    belongs_to :table, :kitchen, :polymorphic => true
  end
end

# Create a TestHelper module with some helpers
class UrlHelpersTest < ActiveSupport::TestCase

  def test_url_helpers_on_simple_inherited_resource
    controller = HousesController.new
    controller.instance_variable_set('@house', :house)

    [:url, :path].each do |path_or_url|
      controller.expects("houses_#{path_or_url}").with({}).once
      controller.send("collection_#{path_or_url}")

      controller.expects("house_#{path_or_url}").with(:house, {}).once
      controller.send("resource_#{path_or_url}")

      controller.expects("new_house_#{path_or_url}").with({}).once
      controller.send("new_resource_#{path_or_url}")

      controller.expects("edit_house_#{path_or_url}").with(:house, {}).once
      controller.send("edit_resource_#{path_or_url}")

      # With arg
      controller.expects("house_#{path_or_url}").with(:arg, {}).once
      controller.send("resource_#{path_or_url}", :arg)

      controller.expects("house_#{path_or_url}").with(:arg, {}).once
      controller.send("resource_#{path_or_url}", :arg)

      # With options
      controller.expects("house_#{path_or_url}").with(:arg, :page => 1).once
      controller.send("resource_#{path_or_url}", :arg, :page => 1)
    end
  end

  def test_url_helpers_on_simple_inherited_namespaced_resource
    controller = Admin::BackpacksController.new
    controller.instance_variable_set('@backpack', :backpack)

    assert_equal 'admin', controller.class.resources_configuration[:self][:route_prefix]

    [:url, :path].each do |path_or_url|
      controller.expects("admin_backpacks_#{path_or_url}").with({}).once
      controller.send("collection_#{path_or_url}")

      controller.expects("admin_backpack_#{path_or_url}").with(:backpack, {}).once
      controller.send("resource_#{path_or_url}")

      controller.expects("new_admin_backpack_#{path_or_url}").with({}).once
      controller.send("new_resource_#{path_or_url}")

      controller.expects("edit_admin_backpack_#{path_or_url}").with(:backpack, {}).once
      controller.send("edit_resource_#{path_or_url}")

      # With arg
      controller.expects("admin_backpack_#{path_or_url}").with(:arg, {}).once
      controller.send("resource_#{path_or_url}", :arg)

      controller.expects("admin_backpack_#{path_or_url}").with(:arg, {}).once
      controller.send("resource_#{path_or_url}", :arg)

      # With options
      controller.expects("admin_backpack_#{path_or_url}").with(:arg, :page => 1).once
      controller.send("resource_#{path_or_url}", :arg, :page => 1)
    end
  end

  def test_url_helpers_on_simple_inherited_singleton_resource
    controller = UniversesController.new
    controller.instance_variable_set('@universe', :universe)

    [:url, :path].each do |path_or_url|
      controller.expects("root_#{path_or_url}").with({}).once
      controller.send("collection_#{path_or_url}")

      controller.expects("universe_#{path_or_url}").with({}).once
      controller.send("resource_#{path_or_url}")

      controller.expects("new_universe_#{path_or_url}").with({}).once
      controller.send("new_resource_#{path_or_url}")

      controller.expects("edit_universe_#{path_or_url}").with({}).once
      controller.send("edit_resource_#{path_or_url}")

      # With options
      # Also tests that argument sent are not used
      controller.expects("universe_#{path_or_url}").with(:page => 1).once
      controller.send("resource_#{path_or_url}", :arg, :page => 1)
    end
  end

  def test_url_helpers_on_belongs_to
    controller = TablesController.new
    controller.instance_variable_set('@house', :house)
    controller.instance_variable_set('@table', :table)

    [:url, :path].each do |path_or_url|
      controller.expects("house_tables_#{path_or_url}").with(:house, {}).once
      controller.send("collection_#{path_or_url}")

      controller.expects("house_table_#{path_or_url}").with(:house, :table, {}).once
      controller.send("resource_#{path_or_url}")

      controller.expects("new_house_table_#{path_or_url}").with(:house, {}).once
      controller.send("new_resource_#{path_or_url}")

      controller.expects("edit_house_table_#{path_or_url}").with(:house, :table, {}).once
      controller.send("edit_resource_#{path_or_url}")

      # With arg
      controller.expects("house_table_#{path_or_url}").with(:house, :arg, {}).once
      controller.send("resource_#{path_or_url}", :arg)

      controller.expects("edit_house_table_#{path_or_url}").with(:house, :arg, {}).once
      controller.send("edit_resource_#{path_or_url}", :arg)

      # With options
      controller.expects("house_table_#{path_or_url}").with(:house, :arg, :page => 1).once
      controller.send("resource_#{path_or_url}", :arg, :page => 1)
    end
  end

  def test_url_helpers_on_not_default_belongs_to
    controller = RoomsController.new
    controller.instance_variable_set('@house', :house)
    controller.instance_variable_set('@room', :room)

    [:url, :path].each do |path_or_url|
      controller.expects("big_house_rooms_#{path_or_url}").with(:house, {}).once
      controller.send("collection_#{path_or_url}")

      controller.expects("big_house_room_#{path_or_url}").with(:house, :room, {}).once
      controller.send("resource_#{path_or_url}")

      controller.expects("new_big_house_room_#{path_or_url}").with(:house, {}).once
      controller.send("new_resource_#{path_or_url}")

      controller.expects("edit_big_house_room_#{path_or_url}").with(:house, :room, {}).once
      controller.send("edit_resource_#{path_or_url}")

      # With args
      controller.expects("big_house_room_#{path_or_url}").with(:house, :arg, {}).once
      controller.send("resource_#{path_or_url}", :arg)

      controller.expects("edit_big_house_room_#{path_or_url}").with(:house, :arg, {}).once
      controller.send("edit_resource_#{path_or_url}", :arg)

      # With options
      controller.expects("big_house_room_#{path_or_url}").with(:house, :arg, :page => 1).once
      controller.send("resource_#{path_or_url}", :arg, :page => 1)
    end
  end

  def test_url_helpers_on_nested_belongs_to
    controller = ChairsController.new
    controller.instance_variable_set('@house', :house)
    controller.instance_variable_set('@table', :table)
    controller.instance_variable_set('@chair', :chair)

    [:url, :path].each do |path_or_url|
      controller.expects("house_table_chairs_#{path_or_url}").with(:house, :table, {}).once
      controller.send("collection_#{path_or_url}")

      controller.expects("house_table_chair_#{path_or_url}").with(:house, :table, :chair, {}).once
      controller.send("resource_#{path_or_url}")

      controller.expects("new_house_table_chair_#{path_or_url}").with(:house, :table, {}).once
      controller.send("new_resource_#{path_or_url}")

      controller.expects("edit_house_table_chair_#{path_or_url}").with(:house, :table, :chair, {}).once
      controller.send("edit_resource_#{path_or_url}")

      # With args
      controller.expects("edit_house_table_chair_#{path_or_url}").with(:house, :table, :arg, {}).once
      controller.send("edit_resource_#{path_or_url}", :arg)

      controller.expects("house_table_chair_#{path_or_url}").with(:house, :table, :arg, {}).once
      controller.send("resource_#{path_or_url}", :arg)

      # With options
      controller.expects("edit_house_table_chair_#{path_or_url}").with(:house, :table, :arg, :page => 1).once
      controller.send("edit_resource_#{path_or_url}", :arg, :page => 1)
    end
  end

  def test_url_helpers_on_singletons_with_belongs_to
    controller = OwnersController.new
    controller.instance_variable_set('@house', :house)
    controller.instance_variable_set('@owner', :owner)

    [:url, :path].each do |path_or_url|
      controller.expects("house_#{path_or_url}").with(:house, {}).once
      controller.send("collection_#{path_or_url}")

      controller.expects("house_owner_#{path_or_url}").with(:house, {}).once
      controller.send("resource_#{path_or_url}")

      controller.expects("new_house_owner_#{path_or_url}").with(:house, {}).once
      controller.send("new_resource_#{path_or_url}")

      controller.expects("edit_house_owner_#{path_or_url}").with(:house, {}).once
      controller.send("edit_resource_#{path_or_url}")

      # With options
      # Also tests that argument sent are not used
      controller.expects("house_owner_#{path_or_url}").with(:house, :page => 1).once
      controller.send("resource_#{path_or_url}", :arg, :page => 1)
    end
  end

  def test_url_helpers_on_polymorphic_belongs_to
    house = House.new
    bed   = Bed.new
    
    new_bed = Bed.new
    Bed.stubs(:new).returns(new_bed)
    new_bed.stubs(:new_record?).returns(true)

    controller = BedsController.new
    controller.instance_variable_set('@parent_type', :house)
    controller.instance_variable_set('@house', house)
    controller.instance_variable_set('@bed', bed)

    [:url, :path].each do |path_or_url|
      controller.expects("house_beds_#{path_or_url}").with(house).once
      controller.send("collection_#{path_or_url}")

      controller.expects("house_bed_#{path_or_url}").with(house, bed).once
      controller.send("resource_#{path_or_url}")

      controller.expects("new_house_bed_#{path_or_url}").with(house).once
      controller.send("new_resource_#{path_or_url}")

      controller.expects("edit_house_bed_#{path_or_url}").with(house, bed).once
      controller.send("edit_resource_#{path_or_url}")
    end

    # With options
    controller.expects("house_bed_url").with(house, bed, :page => 1).once
    controller.send("resource_url", :page => 1)

    # With args
    controller.expects("polymorphic_url").with([house, :arg], {}).once
    controller.send("resource_url", :arg)

    controller.expects("edit_polymorphic_url").with([house, :arg], {}).once
    controller.send("edit_resource_url", :arg)
  end

  def test_url_helpers_on_nested_polymorphic_belongs_to
    house = House.new
    table = Table.new
    dish  = Dish.new

    new_dish = Dish.new
    Dish.stubs(:new).returns(new_dish)
    new_dish.stubs(:new_record?).returns(true)

    controller = DishesController.new
    controller.instance_variable_set('@parent_type', :table)
    controller.instance_variable_set('@house', house)
    controller.instance_variable_set('@table', table)
    controller.instance_variable_set('@dish', dish)

    [:url, :path].each do |path_or_url|
      controller.expects("house_table_dishes_#{path_or_url}").with(house, table).once
      controller.send("collection_#{path_or_url}")

      controller.expects("house_table_dish_#{path_or_url}").with(house, table, dish).once
      controller.send("resource_#{path_or_url}")

      controller.expects("new_house_table_dish_#{path_or_url}").with(house, table).once
      controller.send("new_resource_#{path_or_url}")

      controller.expects("edit_house_table_dish_#{path_or_url}").with(house, table, dish).once
      controller.send("edit_resource_#{path_or_url}")
    end

    # With options
    controller.expects("house_table_dish_url").with(house, table, dish, :page => 1).once
    controller.send("resource_url", :page => 1)

    # With args
    controller.expects("polymorphic_url").with([house, table, :arg], {}).once
    controller.send("resource_url", :arg)

    controller.expects("edit_polymorphic_url").with([house, table, :arg], {}).once
    controller.send("edit_resource_url", :arg)
  end

  def test_url_helpers_on_singleton_nested_polymorphic_belongs_to
    # This must not be usefull in singleton controllers...
    # Center.new
    house = House.new
    table = Table.new

    controller = CentersController.new
    controller.instance_variable_set('@parent_type', :table)
    controller.instance_variable_set('@house', house)
    controller.instance_variable_set('@table', table)

    # This must not be useful in singleton controllers...
    # controller.instance_variable_set('@center', :center)

    [:url, :path].each do |path_or_url|
      controller.expects("house_table_#{path_or_url}").with(house, table).once
      controller.send("collection_#{path_or_url}")

      controller.expects("house_table_center_#{path_or_url}").with(house, table).once
      controller.send("resource_#{path_or_url}")

      controller.expects("new_house_table_center_#{path_or_url}").with(house, table).once
      controller.send("new_resource_#{path_or_url}")

      controller.expects("edit_house_table_center_#{path_or_url}").with(house, table).once
      controller.send("edit_resource_#{path_or_url}")
    end

    # With options
    controller.expects("house_table_center_url").with(house, table, :page => 1)
    controller.send("resource_url", :page => 1)

    # With args
    controller.expects("polymorphic_url").with([house, table, :center], {}).once
    controller.send("resource_url", :arg)
  end

  def test_url_helpers_on_optional_polymorphic_belongs_to
    bed   = Bed.new
    new_bed = Bed.new
    Bed.stubs(:new).returns(new_bed)
    new_bed.stubs(:new_record?).returns(true)

    controller = BedsController.new
    controller.instance_variable_set('@parent_type', nil)
    controller.instance_variable_set('@bed', bed)

    [:url, :path].each do |path_or_url|
      controller.expects("beds_#{path_or_url}").with().once
      controller.send("collection_#{path_or_url}")

      controller.expects("bed_#{path_or_url}").with(bed).once
      controller.send("resource_#{path_or_url}")

      controller.expects("new_bed_#{path_or_url}").with().once
      controller.send("new_resource_#{path_or_url}")

      controller.expects("edit_bed_#{path_or_url}").with(bed).once
      controller.send("edit_resource_#{path_or_url}")
    end

    # With options
    controller.expects("bed_url").with(bed, :page => 1).once
    controller.send("resource_url", :page => 1)

    # With args
    controller.expects("polymorphic_url").with([:arg], {}).once
    controller.send("resource_url", :arg)

    controller.expects("edit_polymorphic_url").with([:arg], {}).once
    controller.send("edit_resource_url", :arg)
  end

end
