# frozen_string_literal: true

require 'spec_helper'

describe Tokenable::Config do
  it 'has the default values' do
    expect(Tokenable::Config.secret).not_to eq(nil)
    expect(Tokenable::Config.secret).to eq(Rails.application.secret_key_base)
    expect(Tokenable::Config.lifespan).to eq(7.days)
  end
end
