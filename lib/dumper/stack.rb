module Dumper
  class Stack
    include Dumper::Utility::ObjectFinder

    DATABASES = {
      :mysql      =>  Dumper::Database::MySQL,
      :postgresql =>  Dumper::Database::PostgreSQL,
      :mongodb    =>  Dumper::Database::MongoDB,
      :redis      =>  Dumper::Database::Redis,
    }

    attr_accessor :rails_env, :dispatcher, :framework, :rackup, :configs

    def initialize(options = {})
      @configs = {}

      # Rackup?
      @rackup = find_instance_in_object_space(Rack::Server)

      # Rails?
      if defined?(::Rails)
        @framework = :rails
        @rails_env = Rails.env.to_s
        @rails_version = Rails::VERSION::STRING
        @is_supported_rails_version = (::Rails::VERSION::MAJOR >= 3)
        DATABASES.each do |key, klass|
          database = klass.new
          next unless config = database.config_for(@rails_env) || database.config_for(options[:additional_env])
          @configs[key] = config
        end

      else
        @framework = :ruby
      end

      # Which dispatcher?
      [ :unicorn, :passenger, :thin, :mongrel, :webrick, :resque ].find do |name|
        @dispatcher = send("#{name}?") ? name : nil
      end
    end

    def to_hash
      {
        framework: @framework,
        rails_env: @rails_env,
        rails_version: @rails_version,
        dispatcher: @dispatcher,
        configs: Hash[@configs.map{|k, config| [ k, config.reject{|k,v| k == :password } ] }]
      }
    end

    # Compatibility
    def supported?
      @is_supported_rails_version && @dispatcher && !@configs.empty?
    end

    # Dispatcher
    def unicorn?
      defined?(::Unicorn::HttpServer) && find_instance_in_object_space(::Unicorn::HttpServer)
    end

    def passenger?
      defined?(::Passenger::AbstractServer) || defined?(::IN_PHUSION_PASSENGER)
    end

    def thin?
      defined?(::Thin::Server) && find_instance_in_object_space(::Thin::Server) ||
        (@rackup && @rackup.server.to_s.demodulize == 'Thin')
    end

    def mongrel?
      # defined?(::Mongrel::HttpServer)
      @rackup and @rackup.server.to_s.demodulize == 'Mongrel'
    end

    def webrick?
      # defined?(::WEBrick::VERSION)
      @rackup and @rackup.server.to_s.demodulize == 'WEBrick'
    end

    def resque?
      defined?(::Resque) && (ENV['QUEUES'] || ENV['QUEUE'])
    end
  end
end
