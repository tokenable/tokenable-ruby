# frozen_string_literal: true

require 'spec_helper'
require 'generator_spec'
require 'generators/tokenable/verifier_generator'

describe Tokenable::Generators::VerifierGenerator, type: :generator do
  destination File.expand_path('../../tmp', __dir__)

  before do
    prepare_destination
  end

  it 'creates the all the files etc' do
    run_generator %w[SomeUser]

    assert_migration 'db/migrate/add_tokenable_verifier_to_some_users.rb'

    assert_file 'app/models/some_user.rb' do |content|
      assert_match(/class SomeUser < ApplicationRecord/, content)
      assert_match(/include Tokenable::Verifier/, content)
    end
  end
end
