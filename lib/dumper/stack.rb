module Dumper
  class Stack
    include Dumper::Utility::ObjectFinder

    DATABASES = {
      :mysql      =>  Dumper::Database::MySQL,
      :postgresql =>  Dumper::Database::PostgreSQL,
      :mongodb    =>  Dumper::Database::MongoDB,
      :redis      =>  Dumper::Database::Redis,
    }

    attr_accessor :rails_env, :dispatcher, :framework, :rackup, :databases

    def initialize(options = {})
      @databases = {}

      # Rackup?
      @rackup = defined?(Rack::Server) && find_instance_in_object_space(Rack::Server)

      # Rails?
      if defined?(::Rails)
        @framework = :rails
        @rails_env = Rails.env.to_s
        @rails_version = Rails::VERSION::STRING
        @is_supported_rails_version = (::Rails::VERSION::MAJOR >= 3)
      else
        @framework = :ruby
      end

      if defined?(MongoMapper)
        MongoMapper.database # Trigger to create a Mongo::DB instance
      end

      DATABASES.each do |key, klass|
        database = klass.new
        next unless database.set_config_for(@rails_env) || database.set_config_for(options[:additional_env])
        if options[key].is_a?(Hash)
          database.custom_options = options[key][:custom_options]
          database.format         = options[key][:format]
        end
        @databases[key] = database
      end

      # Which dispatcher?
      [ :puma, :unicorn, :passenger, :thin, :mongrel, :webrick, :pow, :resque ].find do |name|
        @dispatcher = send("#{name}?") ? name : nil
      end
    end

    def to_hash
      {
        framework: @framework,
        rails_env: @rails_env,
        rails_version: @rails_version,
        dispatcher: @dispatcher,
        configs: Hash[@databases.map{|k, database| [ k, database.config.reject{|k,v| k == :password } ] }]
      }
    end

    # Compatibility
    def supported?
      @is_supported_rails_version && !!@dispatcher && !@databases.empty?
    end

    # Dispatcher
    def puma?
      defined?(::Puma::Runner) && find_instance_in_object_space(::Puma::Runner) || # puma 2.3.0 or later
        (@rackup && @rackup.server.to_s.demodulize == 'Puma')
    end

    def unicorn?
      defined?(::Unicorn::HttpServer) && find_instance_in_object_space(::Unicorn::HttpServer)
    end

    def passenger?
      defined?(::PhusionPassenger) || defined?(::Passenger::AbstractServer) || defined?(::IN_PHUSION_PASSENGER)
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

    def pow?
      # https://github.com/josh/nack/blob/master/bin/nack_worker
      defined?(::Nack::Server) && find_instance_in_object_space(::Nack::Server)
    end

    def resque?
      defined?(::Resque) && (ENV['QUEUES'] || ENV['QUEUE'])
    end
  end
end
