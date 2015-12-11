# ![Hipaa Hippo](http://imgh.us/hipaa-hippo.svg)Hipaapotamus
[![Build Status](https://travis-ci.org/anarchocurious/hipaapotamus.svg)](https://travis-ci.org/anarchocurious/hipaapotamus)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/hipaapotamus`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hipaapotamus'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hipaapotamus

Once the gem is installed, run:

    $ rails generate hipaapotamus:install

and run:

    $ rake db:migrate

to create the hipaapotamus_actions table.

## Usage

### Setting up Agents

Include Hipaapotamus::Agent on any models you want to act as an agent (for example, User) and override the hipaapotamus_display_name method to display whatever agent identifier you like:

```ruby
class User < ActiveRecord::Base
  include Hipaapotamus::Agent
  
  def hipaapotamus_display_name
    email
  end
end
```

### Setting up Protected Models

Include Hipaapotamus::Protected on any models you want to be protected by a Hipaapotamus Policy:

```ruby
class MedicalSecret < ActiveRecord::Base
  include Hipaapotamus::Protected
end
```

### Setting up a Policy

Create a policies folder in your app directory and add your policy as follows (using MedicalSecret from above). Hipaapotamus will automatically against the policy when actions are attempted. When authorizing, the policy has access to the agent and the protected model.

```ruby
class MedicalSecretPolicy < Hipaapotamus::Policy
  def access?
    agent.medical_secrets.include? protected
  end

  def creation?
    agent.medical_secrets.include? protected
  end

  def modification?
    agent.medical_secrets.include? protected
  end

  def destruction?
    agent.medical_secrets.include? protected
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/hipaapotamus.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


