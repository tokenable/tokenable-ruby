# Tokenable

![Test](https://github.com/tokenable/tokenable-ruby/workflows/Test/badge.svg)

Tokenable is a gem for Rails to enable the ability for API applications to provide Authentication.

This allows you to provide authentication to mobile apps, or SPAs with ease.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tokenable', git: 'https://github.com/tokenable/tokenable-ruby.git'
```

And then execute:

```
bundle install
```

## Usage

Once you have the gem installed, lets get it setup:

```bash
rails generate tokenable:install User --strategy=devise
```

We make it easier for you, by adding out of the box support for some auth libraries. You can pick from the following options for `--strategy`, or leave it empty for a custom one (see below):

- [devise](https://github.com/heartcombo/devise)
- [secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html)

This will add a route, the configuration file at `config/initializers/tokenable.rb`, and add the required includes to your User model. There are no migrations to run in the default configuration.

You can also create your own stragery. This is as simple as adding a method to your User model.

```ruby
# The params are passed directly from a controller, so you can do anything with
# them that you normally would within a controller.
def self.from_tokenable_params(params)
  user = User.find_by(something: params[:something])
  return nil unless user.present?

  return nil unless user.password_valid?(params[:password])
  user
end
```

### Invalidate Tokens

Sometime you want to be able to force a user (or users) to login again. You can do this by adding the Verifier. To install this, run:

```
rails generate tokenable:verifier User
```

And then run your migrations:

```
rails db:migrate
```

You can now invalidate all tokens by calling `user.invalidate_tokens!`.

### Token Expiry

By default, tokens will live forever. If you want to change this, you can set a config option (see below for how to set that up).

```ruby
Tokenable::Config.lifespan = 7.days
```

### Example Usage

Once you have this setup, you can login. For example, you could login using `axios` in JavaScript:

```js
const { data } = await axios.post("https://example.com/api/auth", {
  email: "email@example.com",
  password: "coolpassword123",
});

const token = data.data.token;
const user_id = data.data.user_id;
```

You then use this token in all future API requests:

```js
const { data } = await axios.get(`https://example.com/api/user/${user_id}`, {
  headers: { Authorization: `Bearer ${token}` },
});
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/tokenable/tokenable-ruby>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/tokenable/tokenable-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tokenable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tokenable/tokenable-ruby/blob/main/CODE_OF_CONDUCT.md).
