# frozen_string_literal: true

require 'spec_helper'

class NormalUserWithVerifier < User
  include Tokenable::Verifier
end

describe Tokenable::Verifier do
  let(:user) { UserWithVerifier.new }

  describe '#current_verifier' do
    it 'returns the verifier if one is set' do
      verifier = SecureRandom.hex
      user.tokenable_verifier = verifier

      expect(user.current_verifier).to eq(verifier)
    end

    it 'creates a verifier if one is not defined' do
      expect(user.tokenable_verifier).to be_blank
      user.current_verifier
      expect(user.tokenable_verifier).not_to be_blank
    end
  end

  describe '#invalidate_tokens!' do
    it 'creates a new verifier' do
      verifier = SecureRandom.hex
      user.tokenable_verifier = verifier
      expect(user.current_verifier).to eq(verifier)

      user.invalidate_tokens!
      expect(user.current_verifier).not_to be_blank
      expect(user.current_verifier).not_to eq(verifier)
    end
  end

  describe '#valid_verifier?' do
    it 'throws an exception when using a user without Verifier field in DB' do
      expect { NormalUserWithVerifier.new.valid_verifier?('123') }.to raise_error(Tokenable::Unauthorized, 'tokenable_verifier field is missing')
    end

    it 'returns false when using an invalid verifier' do
      verifier = SecureRandom.hex
      user.tokenable_verifier = verifier
      expect(user).not_to be_valid_verifier('123')
    end

    it 'returns true when using a valid verifier' do
      verifier = SecureRandom.hex
      user.tokenable_verifier = verifier
      expect(user).to be_valid_verifier(verifier)
    end
  end
end
