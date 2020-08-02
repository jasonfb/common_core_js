$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "common_core_js/version"
require 'byebug'
# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "common_core_js"
  spec.version     = CommonCoreJs::VERSION
  spec.license     = 'MIT'
  spec.date        = '2020-06-28'
  spec.summary     = "A gem build scaffolding."
  spec.description = "Simple, plug & play Rails scaffolding with really simple Javascript"
  spec.authors     = ["Jason Fleetwood-Boldt"]
  spec.email       = 'jason.fb@datatravels.com'




  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # spec.files = Dir["{app,config,db,lib,vendor}/**/*", "LICENSE", "Rakefile", "README.md"]

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.add_dependency "rails"
  spec.homepage    = 'https://blog.jasonfleetwoodboldt.com/common-core-js/'
  spec.metadata    = { "source_code_uri" => "https://github.com/jasonfb/common_core_js",
                       "documentation_uri" => "https://github.com/jasonfb/common_core_js",
                       "homepage_uri" => 'https://blog.jasonfleetwoodboldt.com/common-core-js/',
                      "mailing_list_uri" => 'https://blog.jasonfleetwoodboldt.com/#sfba-form2-container'
  }

  spec.add_runtime_dependency('kaminari')
  spec.add_runtime_dependency('haml-rails')
  spec.add_runtime_dependency "sass-rails"

  spec.add_runtime_dependency 'bootsnap'
  spec.add_runtime_dependency 'bootstrap'
  spec.add_runtime_dependency 'font-awesome-rails'

  spec.post_install_message = <<~MSG
    ---------------------------------------------
    Welcome to Common Core
    
    rails generate common_score:scaffold Thing

        * Build plug-and-play scaffolding mixing HAML with jQuery-based Javascript
        * Automatically Reads Your Models (make them before building your scaffolding!)
        * Excellent for CRUD, lists with pagination, searching, sorting.
        * Wonderful for prototyping.
        * Plays nicely with Devise, Kaminari, Haml-Rails, Rspec.
        * Create specs autoamatically along with the controllers.
        * Nest your routes model-by-model for built-in poor man's authentication
        * Throw the scaffolding away when your app is ready to graduate to its next phase.

    see README for complete instructions.
    ---------------------------------------------
  MSG
end
