require 'rails/generators/erb/scaffold/scaffold_generator'
require 'ffaker'

module CommonCore
  class InstallGenerator < Rails::Generators::Base
    hook_for :form_builder, :as => :scaffold

    source_root File.expand_path('templates', __dir__)


    def initialize(*args) #:nodoc:
      super

      copy_file "common_core.js", "vendor/assets/javascripts/common_core.js"
      copy_file "common_core.scss", "vendor/assets/stylesheets/common_core.scss"

    end

  end
end



