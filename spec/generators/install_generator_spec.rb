# frozen_string_literal: true

require 'spec_helper'
require 'generator_spec'
require 'generators/tokenable/install_generator'

describe Tokenable::Generators::InstallGenerator, type: :generator do
  destination File.expand_path('../../tmp', __dir__)
  before { prepare_destination }

  describe 'when creating with a strategy' do
    it 'creates the all the files etc' do
      run_generator %w[SomeUser --strategy=devise]

      assert_file 'config/initializers/tokenable.rb' do |content|
        assert_match(/Tokenable::Config.user_class = 'SomeUser'/, content)
        assert_match(/Tokenable::Config.lifespan = 7.days/, content)
        assert_match(/Tokenable::Config.secret = Rails.application.secret_key_base/, content)
      end

      assert_file 'config/routes.rb' do |content|
        assert_match(/mount Tokenable::Engine/, content)
      end

      assert_file 'app/models/some_user.rb' do |content|
        assert_match(/class SomeUser < ApplicationRecord/, content)
        assert_match(/include Tokenable::Strategies::Devise/, content)
      end
    end

    it 'creates the all the files and adds has_secure_password when using secure_password strategy' do
      run_generator %w[SomeUser --strategy=secure_password]

      assert_file 'app/models/some_user.rb' do |content|
        assert_match(/class SomeUser < ApplicationRecord/, content)
        assert_match(/has_secure_password/, content)
        assert_match(/include Tokenable::Strategies::SecurePassword/, content)
      end
    end
  end

  describe 'when creating without a strategy' do
    it 'does not create the model' do
      run_generator %w[SomeOtherUser]
      assert_no_file 'app/models/some_other_user.rb'
    end
  end
end
