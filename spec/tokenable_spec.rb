# frozen_string_literal: true

require 'spec_helper'

describe Tokenable do
  it 'has a version number' do
    expect(Tokenable::VERSION).not_to eq(nil)
  end
end
