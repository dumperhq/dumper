module Dumper
  class Dependency
    LIBS = {
      'thor'       => { :version => '~> 0.19' },
      'rainbow'    => { :version => '~> 2.1', :require => 'rainbow/ext/string' },
      'net-ntp'    => { :version => '~> 2.1', :require => 'net/ntp' },
      'ipaddress'  => { :version => '~> 0.8.3' },
    }

    def self.load(name)
      begin
        gem name, LIBS[name][:version]
        require LIBS[name][:require] || name
      rescue LoadError
        abort <<-EOS
Dependency missing: #{name}
To install the gem, issue the following command:

    gem install #{name} -v '#{LIBS[name][:version]}'

Please try again after installing the missing dependency.
        EOS
      end
    end
  end
end
