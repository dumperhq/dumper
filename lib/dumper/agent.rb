require 'timeout'
require 'net/http'
require 'dumper/patch'

module Dumper
  class Agent
    include Dumper::Utility::Log

    API_VERSION = 1
    MAX_FILESIZE = 2147483648 # 2.gigabytes

    attr_reader :stack, :max_filesize

    class << self
      def start(options = {})
        if defined?(Rails::Railtie)
          ActiveSupport.on_load :after_initialize do
            # Since the first Redis object could be instantiated after our initializer gets run,
            # we start the agent after all initializers are loaded.
            Dumper::Agent.new(options).start
          end
        else
          new(options).start
        end
      end

      def start_if(options = {})
        start(options) if yield
      end
    end

    def initialize(options = {})
      log 'app_key is missing' if options[:app_key].blank?

      @stack = Dumper::Stack.new(options)
      @api_base = options[:api_base] || 'https://dumper.io'
      @app_key = options[:app_key]
      @app_env = @stack.rails_env
      @app_name = ObjectSpace.each_object(Rails::Application).first.class.name.split("::").first
      if options[:debug]
        logger.level = stdout_logger.level = Logger::DEBUG
        Thread.abort_on_exception = true
      end
    end

    def start
      log "stack: #{@stack.to_hash} - supported: #{@stack.supported?}", :debug
      return unless @stack.supported?

      @loop_thread = Thread.new { start_loop }
      @loop_thread[:name] = 'Loop Thread'
    end

    def start_loop
      sec = 1
      register_body = MultiJson.dump(register_hash)
      log "message body for agent/register: #{register_body}", :debug
      begin
        sec *= 2
        log "sleeping #{sec} seconds for agent/register", :debug
        sleep sec
        json = api_request('agent/register', :json => register_body)
      end until json[:status]

      return log("agent stopped: #{json.to_s}") if json[:status] == 'error'

      @token = json[:token]
      @max_filesize = (json[:max_filesize] || MAX_FILESIZE).to_i
      log "agent started as #{@token ? 'primary' : 'secondary'}, max_filesize = #{@max_filesize}"

      sleep 1.hour + rand(10) unless @token

      loop do
        json = api_request('agent/poll', :params => { :token => @token })

        if json[:status] == 'ok'
          # Promoted or demoted?
          if json[:token]
            log 'promoted to primary' if @token.nil?
            @token = json[:token]
          else
            log 'demoted to secondary' if @token
            @token = nil
          end

          if json[:job]
            if pid = fork
              # Parent
              srand # Ruby 1.8.7 needs reseeding - http://bugs.ruby-lang.org/issues/4338
              Process.detach(pid)
            else
              # Child
              Dumper::Job.new(self, json[:job]).run_and_exit
            end
          end
        end

        sleep [ json[:interval].to_i, 60 ].max
      end
    end

    def register_hash
      {
        :hostname => Socket.gethostname,
        :agent_version => Dumper::VERSION,
        :app_name => @app_name,
        :stack => @stack.to_hash,
      }
    end

    def api_request(method_name, options)
      uri = URI.parse("#{@api_base}/api/#{method_name}")
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.is_a? URI::HTTPS
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Post.new(uri.request_uri)
      request['x-app-key'] = @app_key
      request['x-app-env'] = @app_env
      request['x-api-version'] = API_VERSION.to_s
      request['user-agent'] = "Dumper-RailsAgent/#{Dumper::VERSION} (ruby #{::RUBY_VERSION} #{::RUBY_PLATFORM} / rails #{Rails::VERSION::STRING})"
      if options[:params]
        request.set_form_data(options[:params])
      else
        # Without empty string, WEBrick would complain WEBrick::HTTPStatus::LengthRequired for empty POSTs
        request.body = options[:json] || ''
        request['Content-Type'] = 'application/octet-stream'
      end

      response = http.request(request)
      if response.code == '200'
        log response.body, :debug
        MultiJson.load(response.body).with_indifferent_access
      else
        log "******** ERROR on api: #{method_name}, resp code: #{response.code} ********", :error
        {} # return empty hash
      end
    rescue
      log_last_error
      {} # return empty hash
    end
  end
end
