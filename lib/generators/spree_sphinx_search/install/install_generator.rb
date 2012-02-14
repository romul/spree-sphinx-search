module SpreeSphinxSearch
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      def copy_config
        copy_file "sphinx.yml", "config/sphinx.yml"
      end

    end
  end
end
