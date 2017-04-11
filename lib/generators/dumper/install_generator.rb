module Dumper
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      argument :app_key, required: false

      def copy_initializer
        template 'dumper.rb.erb', 'config/initializers/dumper.rb'
      end
    end
  end
end
