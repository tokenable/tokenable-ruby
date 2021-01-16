# Tokenable

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/tokenable`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tokenable'
```

And then execute:

    bundle install

Or install it yourself as:

    gem install tokenable

## Usage

In your `routes.rb`, please add:

```ruby
mount Tokenable::Engine => '/api/auth'
```

And in your `User` model, please add an Auth strategy, such as:

```ruby
class User < ApplicationRecord
  include Tokenable::Strategies::SecurePassword

  has_secure_password
end
```

You can chose from:

- `Tokenable::Strategies::SecurePassword`
- `Tokenable::Strategies::Devise`

You can also create your own stragery. (TODO: link to docs on this)

Once you have this setup, you can login. For example, you could login using `axios` in JavaScript:

```js
const { data } = await axios.post("https://example.com/api/auth", {
  email: "email@example.com",
  password: "coolpassword123",
});

const token = data.data.token;
```

You then use this token in all future API requests:

```js
const { data } = await axios.get("https://example.com/api/user", {
  headers: { Authorization: `Bearer ${token}` },
});
```

### Revocable Tokens

If you want to be able to revoke tokens from the server, then you can add `Tokenable::Revocable`.

```ruby
class User < ApplicationRecord
  include Tokenable::Revocable
end
```

And running the following migration:

```bash
rails g migration AddRevokeTokenableVerifierToUsers tokenable_verifier:uuid
```

You can now invalidate all tokens by calling `user.invalidate_tokens!`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/tokenable/tokenable-ruby>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/tokenable/tokenable-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tokenable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tokenable/tokenable-ruby/blob/main/CODE_OF_CONDUCT.md).
