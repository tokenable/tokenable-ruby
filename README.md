# Tokenable

![Tests](https://github.com/tokenable/tokenable-ruby/workflows/Tests/badge.svg)
[![codecov](https://codecov.io/gh/tokenable/tokenable-ruby/branch/main/graph/badge.svg?token=URF456H8RI)](https://codecov.io/gh/tokenable/tokenable-ruby)
![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)
![Project Status: WIP – Development is in progress](https://www.repostatus.org/badges/latest/wip.svg)

Tokenable is a Rails gem that allows API-only applications a way to authenticate users. This can be helpful when building Single Page Applications, or Mobile Applications.

Simply send a login request to the authentication endpoint, and Tokenable will return a token. This token can then be used to access your API, and any authenticated endpoints.

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

We make it easier for you, by adding out of the box support for some auth libraries. You can pick from the following options for `--strategy`, or leave it empty for a [custom strategy](https://github.com/tokenable/tokenable-ruby/wiki/Create-your-own-statergy):

- [devise](https://github.com/heartcombo/devise)
- [sorcery](https://github.com/Sorcery/sorcery)
- [secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html)

This will add a route, the configuration file at `config/initializers/tokenable.rb`, and add the required includes to your User model. There are no migrations to run in the default configuration.

### Controllers

To limit access to your controllers/endpoints, you will need to include Tokenable.

```ruby
class SomeController < ApplicationController
  include Tokenable::Authable

  before_action :require_tokenable_user!
end
```

After you have done this, the following methods are available:

- `current_user`
- `user_signed_in?`

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

By default, tokens expire after 7 days. If you want to change this, you can set a config option.

```ruby
# Expire in 7 days (default)
Tokenable::Config.lifespan = 7.days

# Tokens will never expire
Tokenable::Config.lifespan = nil
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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/tokenable/tokenable-ruby>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/tokenable/tokenable-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tokenable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tokenable/tokenable-ruby/blob/main/CODE_OF_CONDUCT.md).
