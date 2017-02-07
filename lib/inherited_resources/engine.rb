module InheritedResources
  class Railtie < ::Rails::Engine
    config.inherited_resources = InheritedResources

    if config.respond_to?(:app_generators)
      config.app_generators.scaffold_controller = :inherited_resources_controller
    else
      config.generators.scaffold_controller = :inherited_resources_controller
    end
  end
end
