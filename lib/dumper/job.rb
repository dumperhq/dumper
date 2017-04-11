require 'ostruct'
require 'posix/spawn'

module Dumper
  class Job
    include POSIX::Spawn
    include Dumper::Utility::Log

    def initialize(agent, job)
      @agent = agent
      @job = job
    end

    def run_and_exit
      @job[:servers].each do |server|
        perform(server)
      end
    ensure
      log_last_error if $!
      log 'exiting...'
      exit!(true) # Do not use exit or abort to skip at_exit execution, or pid could get deleted on thin
    end

    def perform(server)
      # Find database
      server_type = server[:type].to_sym
      abort_with "invalid server type: #{server_type}" unless Dumper::Stack::DATABASES.keys.include?(server_type)
      return log "database not found: #{@database.inspect}" unless @database = @agent.stack.databases[server_type]

      # Prepare
      json = @agent.api_request('backup/prepare', :params => { :server_id => server[:id], :manual => server[:manual].to_s, :ext => @database.file_ext })
      abort_with('backup/prepare failed') unless json[:status] == 'ok'

      @backup_id = json[:backup][:id]

      # Dump
      start_at = Time.now
      @database.tmpdir = Dir.mktmpdir
      @database.filename = json[:backup][:filename]
      log 'starting backup...'
      log "tmpdir = #{@database.tmpdir}, filename = #{@database.filename}"
      log "command = #{@database.command}"

      begin
        pid, stdin, stdout, stderr = popen4(@database.command)
        stdin.close
        (out = stdout.read).empty? or log out, :debug
        (err = stderr.read).empty? or log err, :error
      rescue
        Process.kill(:INT, pid) rescue SystemCallError
        abort_with("dump error: #{$!}", :dump_error)
      ensure
        [stdin, stdout, stderr].each{|io| io.close unless io.closed? }
        Process.waitpid(pid)
      end

      dump_duration = Time.now - start_at
      @filesize = File.size(@database.dump_path)
      log "dump_duration = #{dump_duration}, filesize = #{@filesize}"
      if @filesize > @agent.max_filesize
        abort_with("max filesize exceeded: #{@filesize}", :too_large)
      end

      upload_to_s3(json)

      json = @agent.api_request('backup/commit', :params => { :backup_id => @backup_id, :dump_duration => dump_duration.to_i })
    rescue
      log_last_error
    ensure
      @database.finalize
    end

    # Upload
    def upload_to_s3(json)
      if defined?(AWS::S3::MultipartUpload) and @filesize > 100.megabytes
        # aws-sdk gem installed
        upload_by_aws_sdk(json)
      else
        # fallback to multipart-post
        upload_by_multipart_post(json)
      end
    rescue
      abort_with("upload error: #{$!} - please contact our support.", :upload_error)
    end

    def upload_by_aws_sdk(json)
      log "uploading by aws-sdk v#{AWS::VERSION}"

      s3 = json[:s3_federation]
      aws = AWS::S3.new s3[:credentials].merge(region: s3[:region])

      retry_count = 0
      begin
        aws.buckets[s3[:bucket]].objects[s3[:key]].write(
          file: @database.dump_path,
          content_type: 'application/octet-stream',
          content_disposition: "attachment; filename=#{@database.filename}",
        )
      rescue # Errno::ECONNRESET, Errno::EPIPE, etc.
        raise if retry_count > 8
        retry_count += 1
        log "upload failed: #{$!} - retrying after #{2 ** retry_count}sec..."
        sleep 2 ** retry_count
        retry
      end
    end

    def upload_by_multipart_post(json)
      require 'net/http/post/multipart'
      log "uploading by multipart-post v#{Gem.loaded_specs['multipart-post'].version.to_s}"

      fields = json[:fields]
      fields['file'] = UploadIO.new(@database.dump_path, 'application/octet-stream', @database.filename)
      uri = URI.parse(json[:url])
      request = Net::HTTP::Post::Multipart.new uri.path, fields
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.is_a? URI::HTTPS
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      retry_count = 0
      begin
        response = http.request(request)
      rescue # Errno::ECONNRESET, Errno::EPIPE, etc.
        raise if retry_count > 8
        retry_count += 1
        fields['file'].rewind
        log "upload failed: #{$!} - retrying after #{2 ** retry_count}sec..."
        sleep 2 ** retry_count
        retry
      end

      log "response from S3 = #{response.to_s} - #{response.body}"

      # http://apidock.com/ruby/Net/HTTPResponse
      case response
      when Net::HTTPSuccess
        true
      else
        abort_with("upload error: #{response.to_s} - #{response.body}", :upload_error)
      end
    end

    def abort_with(text, code=nil)
      log text
      @database.try(:finalize)
      if code
        @agent.api_request('backup/fail', :params => { :backup_id => @backup_id, :code => code.to_s, :message => text })
      end
      log 'aborting...'
      exit!
    end
  end
end
