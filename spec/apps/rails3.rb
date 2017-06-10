class Rails3 < Rails::Application
  config.root = Pathname.new(__FILE__).parent.parent
end

Rails3.initialize!
