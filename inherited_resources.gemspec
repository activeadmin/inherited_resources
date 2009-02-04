Gem::Specification.new do |s|
  s.name     = "inherited_resources"
  s.version  = "0.1"
  s.date     = "2009-02-04"
  s.summary  = "Inherited Resources speeds up development by making your controllers inherit all restful actions so you just have to focus on what is important."
  s.email    = "jose.valim@gmail.com"
  s.homepage = "http://github.com/josevalim/inherited_resources"
  s.description = "Inherited Resources speeds up development by making your controllers inherit all restful actions so you just have to focus on what is important."
  s.has_rdoc = true
  s.authors  = [ "José Valim" ]
  s.files    = [
    "CHANGELOG",
    "MIT-LICENSE",
    "README",
    "Rakefile",
    "init.rb",
    "lib/inherited_resources.rb",
    "lib/inherited_resources/base.rb",
    "lib/inherited_resources/base_helpers.rb",
    "lib/inherited_resources/belongs_to.rb",
    "lib/inherited_resources/belongs_to_helpers.rb",
    "lib/inherited_resources/class_methods.rb",
    "lib/inherited_resources/polymorphic_helpers.rb",
    "lib/inherited_resources/respond_to.rb",
    "lib/inherited_resources/singleton_helpers.rb",
    "lib/inherited_resources/url_helpers.rb"
  ]
  s.test_files = [
    "test/aliases_test.rb",
    "test/base_helpers_test.rb",
    "test/base_test.rb",
    "test/belongs_to_base_test.rb",
    "test/belongs_to_test.rb",
    "test/class_methods_test.rb",
    "test/fixtures/en.yml",
    "test/nested_belongs_to_test.rb",
    "test/polymorphic_base_test.rb",
    "test/respond_to_test.rb",
    "test/singleton_base_test.rb",
    "test/test_helper.rb",
    "test/url_helpers_test.rb",
    "test/views/cities/edit.html.erb",
    "test/views/cities/index.html.erb",
    "test/views/cities/new.html.erb",
    "test/views/cities/show.html.erb",
    "test/views/comments/edit.html.erb",
    "test/views/comments/index.html.erb",
    "test/views/comments/new.html.erb",
    "test/views/comments/show.html.erb",
    "test/views/employees/edit.html.erb",
    "test/views/employees/index.html.erb",
    "test/views/employees/new.html.erb",
    "test/views/employees/show.html.erb",
    "test/views/managers/edit.html.erb",
    "test/views/managers/new.html.erb",
    "test/views/managers/show.html.erb",
    "test/views/pets/edit.html.erb",
    "test/views/professors/edit.html.erb",
    "test/views/professors/index.html.erb",
    "test/views/professors/new.html.erb",
    "test/views/professors/show.html.erb",
    "test/views/projects/index.html.erb",
    "test/views/projects/respond_to_with_resource.html.erb",
    "test/views/students/edit.html.erb",
    "test/views/students/new.html.erb",
    "test/views/users/edit.html.erb",
    "test/views/users/index.html.erb",
    "test/views/users/new.html.erb",
    "test/views/users/show.html.erb"
  ]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
end
