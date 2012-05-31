# Dumper Agent for Rails

Dumper is a backup management system that offers a whole new way to take daily backups of your databases.

**This app will be launched soon!**

## Supported Stacks

* Ruby 1.8.7 , Ruby 1.9.2 or later
* Rails 3.0 or later
* MySQL with ActiveRecord

Support for PostgreSQL, MongoDB and Redis are coming soon.

## Installation

Add the following line to your Rails project Gemfile:

```ruby
gem 'dumper'
```

then create `config/initializers/dumper.rb` and put the following line.

```ruby
Dumper::Agent.start(:app_key => 'YOUR_APP_KEY')
```

or, if you want to conditionally start the agent, pass a block that evaluates to true/false to `#start_if` method.

```ruby
Dumper::Agent.start_if(:app_key => 'YOUR_APP_KEY') { Rails.env.production? && dumper_enabled_host? }
```

That's it!

Now, start your server and go to the Dumper site.

You'll find your application is registered and ready to take backups daily.
