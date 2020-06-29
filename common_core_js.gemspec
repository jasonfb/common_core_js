$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "common_core_js/version"

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

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.0.3", ">= 6.0.3.2"
  spec.homepage    = 'https://blog.jasonfleetwoodboldt.com/common-core-js/'
  spec.metadata    = { "source_code_uri" => "https://github.com/jasonfb/common_core_js",
                       "documentation_uri" => "https://github.com/jasonfb/common_core_js",
                       "homepage_uri" => 'https://blog.jasonfleetwoodboldt.com/common-core-js/',
                      "mailing_list_uri" => 'https://blog.jasonfleetwoodboldt.com/#sfba-form2-container'
  }

  spec.add_runtime_dependency('kaminari', '> 1', '>= 1.2.1')
  spec.add_runtime_dependency('haml-rails', '> 2', '>= 2.0.1')

  spec.add_development_dependency('simplecov', '~> 0.17', '> 0.17')


  spec.post_install_message = <<~MSG
    ---------------------------------------------
    Welcome to Common Core
    
    rails generate common_score:scaffold Thing

        * Build plug-and-play scaffolding mixing HAML with jQuery-based Javascript
        * Automatically Reads Your Models (make them first!)
        * Excellent for CRUD, lists with pagination, searching, sorting.
        * Wonderful for prototyping
        * Plays with Devise, Kaminari, Haml-Rails
        * Nest your routes model-by-model for built-in poor man's authentication
        * Throw it away when you're done. 

    see README for complete instructions.
    ---------------------------------------------
  MSG

end
