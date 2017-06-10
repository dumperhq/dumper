module Rails4
  class Application < Rails::Application
    config.root = Pathname.new(__FILE__).parent.parent
    config.eager_load = false # to suppress warning
  end
end

Rails4::Application.initialize!
