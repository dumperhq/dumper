module Dumper
  class Stack
    include Dumper::Utility::ObjectFinder

    DATABASES = {
      :mysql      =>  Dumper::Database::MySQL,
      :postgresql =>  Dumper::Database::PostgreSQL,
      :mongodb    =>  Dumper::Database::MongoDB,
      :redis      =>  Dumper::Database::Redis,
    }

    attr_accessor :dispatcher, :framework, :rackup, :databases

    def initialize(options = {})
      @databases = {}

      # Rackup?
      @rackup = first_instance_of('Rack::Server')

      # Rails?
      if defined?(::Rails)
        @framework = :rails
        @is_supported_rails_version = (::Rails::VERSION::MAJOR >= 3)
      else
        @framework = :ruby
      end

      DATABASES.each do |key, klass|
        database = klass.new
        next unless database.set_config || database.set_config { options[:additional_env] }
        if options[key].is_a?(Hash)
          database.custom_options = options[key][:custom_options]
          database.format         = options[key][:format]
        end
        @databases[key] = database
      end

      # Which dispatcher?
      [:puma, :unicorn, :passenger, :thin, :webrick, :pow, :resque].find do |name|
        @dispatcher = send("#{name}?") ? name : nil
      end
    end

    def to_hash
      {
        framework: @framework,
        rails_env: Rails.env,
        rails_version: Rails::VERSION::STRING,
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
      has_instance_of?('::Puma::Runner') || # puma 2.3.0 or later
        rackup_with?('Puma')
    end

    def unicorn?
      has_instance_of?('::Unicorn::HttpServer')
    end

    def passenger?
      defined?(::PhusionPassenger) || defined?(::Passenger::AbstractServer) || defined?(::IN_PHUSION_PASSENGER)
    end

    def thin?
      has_instance_of?('::Thin::Server') || rackup_with?('Thin')
    end

    def webrick?
      rackup_with?('WEBrick')
    end

    def pow?
      # https://github.com/josh/nack/blob/master/bin/nack_worker
      has_instance_of?('::Nack::Server')
    end

    def resque?
      defined?(::Resque) && (ENV['QUEUES'] || ENV['QUEUE'])
    end

  private

    def rackup_with?(name)
      @rackup && @rackup.server.to_s.demodulize == name
    end
  end
end
