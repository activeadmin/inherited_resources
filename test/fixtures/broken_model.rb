# frozen_string_literal: true

# Autoloaded as BrokenModel by tests. It fails the way a model does when
# something it depends on is missing: with a NameError about another constant.
raise NameError.new('uninitialized constant SomeDependency::Missing', :Missing)
