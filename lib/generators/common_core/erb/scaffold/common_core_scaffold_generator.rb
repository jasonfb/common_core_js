module Erb
  module Generators
    class CommonCoreScaffoldGenerator < Rails::Generators::NamedBase

      include Rails::Generators::ResourceHelpers

      # BECAUSE THIS CLASS REPLACES Erb::Generators::Base
      def formats
        [format]
      end

      def format
        nil
      end

      def handler
        :erb
      end

      def filename_with_extensions(name, file_format = format)
        byebug
        [name, file_format, handler].compact.join(".")
      end
    end
  end
end