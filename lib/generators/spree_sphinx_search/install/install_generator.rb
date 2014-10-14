module SpreeSphinxSearch
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      def copy_config
        copy_file "thinking_sphinx.yml", "config/thinking_sphinx.yml"
      end

    end
  end
end
