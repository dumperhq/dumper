module Rails5
  class Application < Rails::Application
    config.root = Pathname.new(__FILE__).parent.parent
    config.eager_load = false # to suppress warning
  end
end

Rails5::Application.initialize!
