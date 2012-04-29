module Dumper
  class Cli < Thor
    include Thor::Actions

    desc 'doctor', 'Check configurations'
    def doctor
      check_ip
      check_cnf
    end

    no_tasks do
      def check_ip
        puts 'Checking IP address...'
        @ip = Dumper::Utility::IP.new
        str = "#{@ip.ip} ... "
        if @ip.ipaddr.private?
          str << 'private'.color(:red)
        else
          str << 'public'.color(:green)
        end
        puts str
      end

      def check_cnf
        puts 'Checking my.cnf...'
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
            puts 'There is bind-address = 127.0.0.1 ... ' << 'fail'.color(:red)
          elsif IPAddr.new(bound).private?
            puts "There is bind-address = #{bound} ... " << 'fail'.color(:red)
          end
        else
          puts 'No bind-address defined in my.cnf ... ' << 'ok'.color(:green)
        end
      end
    end
  end
end
