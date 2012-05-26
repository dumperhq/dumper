module Dumper
  class Dependency
    LIBS = {
      'thor' =>       { :require => 'thor',       :version => '~> 0.14.0' },
      'rainbow' =>    { :require => 'rainbow',    :version => '~> 1.1.4' },
    }

    def self.load(name)
      begin
        gem(name, LIBS[name][:version])
        require(LIBS[name][:require])
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
