# frozen_string_literal: true

require 'spec_helper'

describe Tokenable::Config do
  it 'has the default values' do
    expect(described_class.user_class).to eq(User)
    expect(described_class.secret).not_to eq(nil)
    expect(described_class.secret).to eq(Rails.application.secret_key_base)
    expect(described_class.lifespan).to eq(7.days)
  end

  it 'ensures setters are working' do
    expect(described_class.secret).to eq(Rails.application.secret_key_base)

    random_string = SecureRandom.hex
    described_class.secret = random_string
    expect(described_class.secret).to eq(random_string)
  end

  it 'ensures method_missing is working as expected' do
    expect(described_class.respond_to?(:secret)).to eq(true)
    expect(described_class.secret).to eq(Rails.application.secret_key_base)

    expect { described_class.not_a_thing }.to raise_error(NoMethodError)
    expect(described_class.respond_to?(:not_a_thing)).to eq(false)
  end

  it 'ensures user_class returns a class, when a string is defined' do
    described_class.user_class = 'User'

    expect(described_class.class_variable_get('@@user_class')).to be_a(String)
    expect(described_class.user_class).to eq(User)
  end
end
