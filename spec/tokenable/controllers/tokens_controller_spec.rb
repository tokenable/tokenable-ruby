# frozen_string_literal: true

require 'spec_helper'

describe Tokenable::TokensController, type: :controller do
  controller Tokenable::TokensController do
  end

  before { Tokenable::Config.user_class = UserWithPassword }

  describe 'when no email/password is sent' do
    it 'returns the correct header and error' do
      post :create
      expect(response.status).to eq(401)
      expect(response.parsed_body['error']).to eq('Login failed, please try again.')
    end
  end

  describe 'when the incorrect password is sent' do
    let(:password) { SecureRandom.hex }
    let(:user) { UserWithPassword.create!(email: 'user@example.com', password: password) }

    it 'returns the correct header and error' do
      post :create, params: { email: user.email, password: 'randompassword' }

      expect(response.status).to eq(401)
      expect(response.parsed_body['error']).to eq('Login failed, please try again.')
    end
  end

  describe 'when the correct email/password is sent' do
    let(:password) { SecureRandom.hex }
    let(:user) { UserWithPassword.create!(email: 'user@example.com', password: password) }

    it 'returns the token and user_id' do
      post :create, params: { email: user.email, password: password }

      expect(response.parsed_body['data']['user_id']).to eq(user.id)
      expect(response.parsed_body['data']['token']).not_to eq be_nil

      token = response.parsed_body['data']['token']
      jwt = JWT.decode(token, Tokenable::Config.secret).first
      expect(jwt['data']['user_id']).to eq(user.id)
    end
  end
end
