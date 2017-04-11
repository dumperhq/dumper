module Dumper
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      desc <<DESC
Description:
    Copies Dumper configuration file to your application's initializer directory.
DESC
      def copy_initializer
        template 'dumper.rb', 'config/initializers/dumper.rb'
      end
    end
  end
end
