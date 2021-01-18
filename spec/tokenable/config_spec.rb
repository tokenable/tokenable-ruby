# frozen_string_literal: true

require 'spec_helper'

describe Tokenable::Config do
  it 'has the default values' do
    expect(Tokenable::Config.secret).not_to eq(nil)
    expect(Tokenable::Config.secret).to eq(Rails.application.secret_key_base)
    expect(Tokenable::Config.lifespan).to eq(7.days)
  end

  it 'ensures setters are working' do
    expect(Tokenable::Config.secret).to eq(Rails.application.secret_key_base)

    random_string = SecureRandom.hex
    Tokenable::Config.secret = random_string
    expect(Tokenable::Config.secret).to eq(random_string)
  end

  it 'ensures method_missing is working as expected' do
    expect(Tokenable::Config.respond_to?(:secret)).to eq(true)
    expect(Tokenable::Config.secret).to eq(Rails.application.secret_key_base)

    expect{Tokenable::Config.not_a_thing}.to raise_error(NoMethodError)
    expect(Tokenable::Config.respond_to?(:not_a_thing)).to eq(false)
  end
end
