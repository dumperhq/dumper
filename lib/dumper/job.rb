require 'posix/spawn'

module Dumper
  class Job
    include POSIX::Spawn
    include Dumper::Utility::LoggingMethods

    def initialize(agent, job)
      @agent = agent
      @stack = agent.stack
      @job = job
    end

    def run_and_exit
      @job[:servers].each do |server|
        perform(server)
      end
    ensure
      log_last_error if $!
      log 'exiting...'
      exit
    end

    def perform(server)
      # Prepare
      json = @agent.send_request(api: 'backup/prepare', params: { server_id: server[:id], manual: server[:manual].to_s })
      return unless json[:status] == 'ok'

      case server[:type]
      when 'mysql'
        @database = Dumper::Database::MySQL.new(@stack)
      else
        abort 'invalid server type!' # TBD
      end
      backup_id = json[:backup][:id]
      filename = json[:backup][:filename]

      # Dump
      start_at = Time.now
      tempfile = ruby19? ? Tempfile.new(filename, encoding: 'ascii-8bit') : Tempfile.new(filename)
      log 'starting backup...'
      log "tempfile = #{tempfile.path}"
      log "command = #{@database.command}"

      begin
        pid, stdin, stdout, stderr = popen4(@database.command)
        stdin.close
        # Reuse buffer: http://www.ruby-forum.com/topic/134164
        buffer_size = 1.megabytes
        buffer = "\x00" * buffer_size # fixed-size malloc optimization
        while stdout.read(buffer_size, buffer)
          tempfile.write buffer
          if tempfile.size > Backup::MAX_FILESIZE
            raise 'Max filesize exceeded.'
          end
        end
      rescue
        Process.kill(:INT, pid) rescue SystemCallError
        @agent.send_request(api: 'backup/fail', params: { backup_id: backup_id, code: 'dump_error', message: $!.to_s })
        abort
      ensure
        [stdin, stdout, stderr].each{|io| io.close unless io.closed? }
        Process.waitpid(pid)
      end

      tempfile.flush

      dump_duration = Time.now - start_at
      log "dump_duration = #{dump_duration}"

      upload_to_s3(json[:url], json[:fields], tempfile.path, filename)

      json = @agent.send_request(api: 'backup/commit', params: { backup_id: backup_id, dump_duration: dump_duration.to_i })
    rescue
      log_last_error
    ensure
      tempfile.close(true)
    end

    # Upload
    def upload_to_s3(url, fields, local_file, remote_file)
      require 'net/http/post/multipart'
      fields['file'] = UploadIO.new(local_file, 'application/octet-stream', remote_file)
      uri = URI.parse(url)
      request = Net::HTTP::Post::Multipart.new uri.path, fields
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.is_a? URI::HTTPS
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      response = http.request(request)
      log "response from S3 = #{response.to_s}"
      response
    rescue
      log_last_error
    end

    # Helper
    def ruby19?
      RUBY_VERSION >= '1.9.0'
    end
  end
end
