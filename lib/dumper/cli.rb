Dumper::Dependency.load('thor')
Dumper::Dependency.load('rainbow')
Dumper::Dependency.load('net-ntp')

module Dumper
  class Cli < Thor
    include Thor::Actions

    desc 'doctor', 'Check configurations'
    def doctor
      check_ip
      check_cnf
      check_clock
    end

    no_tasks do
      def check_ip
        print 'Checking IP address... '
        ip = Dumper::Utility::IP.new
        print "#{ip.address} => "
        if ip.private?
          puts "Private IP, #{fetch_will_fail_warning}".color(:red)
        else
          puts 'Public IP, good'.color(:green)
        end
      end

      def check_cnf
        print 'Checking my.cnf... '
        bound = nil
        ['/etc/my.cnf', '/etc/mysql/my.cnf', '/usr/etc/my.cnf', '~/.my.cnf'].each do |name|
          fullpath = File.expand_path(name)
          next unless File.exist?(fullpath)
          File.readlines(fullpath).each do |line|
            if line =~ /^bind-address/
              bound = line.split('=').last.strip
              break
            end
          end
        end
        if bound
          if bound == '127.0.0.1'
            print 'There is bind-address = 127.0.0.1 => '
          elsif IPAddr.new(bound).private?
            print "There is bind-address = #{bound} => "
          end
          puts fetch_will_fail_warning.color(:red)
        else
          puts 'No bind-address defined in my.cnf => ' << 'good'.color(:green)
        end
      end

      def check_clock
        print 'Checking server clock accuracy... '
        target = Net::NTP.get('us.pool.ntp.org').time
        source = Time.now
        diff = (target - source).abs.round(3)
        print "#{source.strftime('%Y-%m-%d %H:%M:%S')} (server time) vs #{target.strftime('%Y-%m-%d %H:%M:%S')} (ntp time), diff: #{diff} seconds => "
        if diff > 15 * 60
          puts 'warning, Amazon S3 does not accept clock skewed more than 15 minutes.'.color(:red)
        else
          puts 'good'.color(:green)
        end
      end

      def fetch_will_fail_warning
        'warning - remote fetch from dumper.io to this server will fail. You will need to use the dumper gem with rails.'
      end
    end
  end
end
