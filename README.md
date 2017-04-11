# Dumper Agent for Rails

[Dumper](http://dumper.io/) is a backup management system that offers a whole new way to perform automated backups of your databases.

## Supported Stacks

* Ruby 1.8.7 or later
* Rails 3.0 or later
* MySQL with ActiveRecord
* PostgreSQL with ActiveRecord
* MongoDB with Mongoid or MongoMapper
* Redis with the redis gem - **limitation: you must run agent on the Redis host**
* Agent runs inside [thin](http://code.macournoyer.com/thin/), [unicorn](http://unicorn.bogomips.org/), [passenger](http://www.modrails.com/), [puma](http://puma.io) or [resque](https://github.com/defunkt/resque) (mongrel and webrick are also supported for development)

## Installation

Add the following line to your Rails project Gemfile:

```ruby
gem 'dumper'
```

If your database is larger than 300MB, it is recommended to also include `aws-sdk` gem for maximum stability.

```ruby
gem 'aws-sdk', '>= 1.8.1.2', '< 2.0'
gem 'dumper'
```

then run the installer:

```ruby
rails g dumper:install [YOUR_APP_KEY]
```

or manually create `config/initializers/dumper.rb` and add the following line:

```ruby
Dumper::Agent.start(:app_key => 'YOUR_APP_KEY')
```

That's it!

Now, start your server and go to the Dumper site.

You'll find your application is registered and ready to take backups.

## How does it work?

In a Rails app server process, a new thread is created and periodically checks the Dumper API to see if a new backup job is scheduled.

When it finds a job, the agent won't run the job inside its own thread, but instead spawns a new process, then goes back to sleep. That way, web requests won't be affected by the long-running backup task, and the task will continue to run even when the parent process is killed in the middle.

Dumper agent will try to run on every process by default. Which means, for instance, if you have 10 thin instances on production, the agent will run on those 10 instances. We designate the first agent that hits our API as primary, and the rest as secondary. In this case, 1 thin process becomes the primary and other 9 processes become secondaries. Only the primary is responsible for taking backup jobs, so it is guaranteed that there is no duplicate work on your servers. The primary polls our API with every 1- to 10-minute interval, while the secondaries poll every hour. If you run fork-based servers like unicorn or passenger, however, the agent thread runs only on the master process, not on child processes.

We do this for fault tolerance. When something goes wrong and the primary dies, one of the secondaries will take over the primary status and continue to serve.

The bottom line is that the agent is designed to be extremely efficient in CPU, memory and bandwidth usage. It's almost impossible to detect any difference in performance with or without it.

## Conditionally start the agent

As explained above, the Dumper agent will try to run on every process by default.

If you want to start the agent on a particular host, pass a block that evaluates to true or false to the `start_if` method.

```ruby
Dumper::Agent.start_if(:app_key => 'YOUR_APP_KEY') do
  Rails.env.production? && dumper_enabled_host?
end
```

Currently Redis support is limited in that you must run the agent on the same host with Redis.

```ruby
Dumper::Agent.start_if(:app_key => 'YOUR_APP_KEY') do
  Socket.gethostname == 'redis.mydomain.com'
end
```

If you are using resque, it's a good idea to run it on the same host with Redis, and start the agent on the resque instance.

## Debugging

If the agent doesn't seem to work, pass `true` to the `debug` option.

```ruby
Dumper::Agent.start(app_key: 'YOUR_APP_KEY', debug: true)
```

It gives verbose logging that helps us to understand the problem.

## Custom Options

You can also pass custom dump options, with `custom_options` and `format` for the database type.

```ruby
Dumper::Agent.start(
  app_key: 'YOUR_APP_KEY',
  postgresql: {
    format: 'dump',
    custom_options: '-Fc --no-acl --no-owner'
  }
)
```
