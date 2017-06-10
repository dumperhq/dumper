class Rails3 < Rails::Application
  config.root = Pathname.new(__FILE__).parent.parent
  config.active_support.deprecation = :stderr
end

Rails3.initialize!
