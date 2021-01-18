# frozen_string_literal: true

# Used for testing when they have included the module, but not ran the migrations
class NormalUserWithVerifier < User
  include Tokenable::Verifier
end

class ControllerWithModule
  include Tokenable::Authable
end

describe Tokenable::Authable, type: :controller do
  controller ApplicationController do
    include Tokenable::Authable
    before_action :require_tokenable_user!

    def index
      @user = current_user
      render plain: 'Hello World'
    end
  end

  subject { -> { get :index } }

  describe 'when generating a token' do
    let(:user) { User.create! }
    let(:token) { ControllerWithModule.new.send(:token_from_user, user) }
    let(:jwt) { JWT.decode(token, Tokenable::Config.secret).first }

    it 'contains the user_id' do
      expect(jwt['data']['user_id']).to eq(user.id)
    end

    describe 'when expiry is enabled' do
      before do
        Tokenable::Config.lifespan = 1.minute
      end

      it 'contains an expiry time' do
        expect(jwt).to have_key('exp')
        expect(jwt['exp']).to be_between(1.minute.ago.to_i, 1.minute.from_now.to_i)
      end
    end

    describe 'when expiry is disabled' do
      before do
        Tokenable::Config.lifespan = nil
      end

      it 'does not contain the expiry time' do
        expect(jwt).not_to have_key('exp')
      end
    end

    describe 'when verifier is disabled' do
      it 'does not contain the verifier' do
        expect(jwt).not_to have_key('verifier')
      end
    end

    describe 'when verifier is enabled' do
      let(:verifier) { SecureRandom.hex }
      let(:user) { UserWithVerifier.create!(tokenable_verifier: verifier) }

      before do
        Tokenable::Config.user_class = UserWithVerifier
      end

      it 'contains the verifier' do
        expect(jwt['data']).to have_key('verifier')
        expect(jwt['data']['verifier']).to eq(verifier)
      end
    end
  end

  describe 'when no token is provided' do
    it { is_expected.to raise_error(Tokenable::Unauthorized, 'Bearer token not provided') }
  end

  describe 'when an invalid JWT token is provided' do
    before { request.headers['Authorization'] = 'Bearer 123' }

    it { is_expected.to raise_error(Tokenable::Unauthorized, 'JWT exception thrown') }
  end

  describe 'when a valid JWT token is provided, but the secret does not match' do
    let(:jwt_data) do
      {
        data: {
          user_id: SecureRandom.hex,
        },
      }
    end

    before do
      request.headers['Authorization'] = "Bearer #{JWT.encode(jwt_data, Tokenable::Config.secret, "HS256")}"
      Tokenable::Config.secret = SecureRandom.hex
    end

    it { is_expected.to raise_error(Tokenable::Unauthorized, 'The tokenable secret used in this token does not match the one supplied in Tokenable::Config.secret') }
  end

  describe 'when a valid JWT token is provided, but the user does not exist' do
    let(:jwt_data) do
      {
        data: {
          user_id: SecureRandom.hex,
        },
      }
    end

    before { request.headers['Authorization'] = "Bearer #{JWT.encode(jwt_data, Tokenable::Config.secret, "HS256")}" }

    it { is_expected.to raise_error(Tokenable::Unauthorized, 'User is not signed in') }
  end

  describe 'when a valid JWT token is provided, but it has expired' do
    let(:jwt_data) do
      {
        exp: 1.minute.ago.to_i,
        data: {
          user_id: User.create!.id,
        },
      }
    end

    before { request.headers['Authorization'] = "Bearer #{JWT.encode(jwt_data, Tokenable::Config.secret, "HS256")}" }

    it { is_expected.to raise_error(Tokenable::Unauthorized, 'Token has expired') }
  end

  describe 'when a valid JWT token is provided, and it has not expired, but the tokenable_verifier is missing' do
    let(:user) { User.create! }
    let(:jwt_data) do
      {
        exp: 1.minute.from_now.to_i,
        data: {
          user_id: user.id,
        },
      }
    end

    before do
      Tokenable::Config.user_class = NormalUserWithVerifier
      request.headers['Authorization'] = "Bearer #{JWT.encode(jwt_data, Tokenable::Config.secret, "HS256")}"
    end

    it { is_expected.to raise_error(Tokenable::Unauthorized, 'tokenable_verifier field is missing') }
  end

  describe 'when a valid JWT token is provided, and it has not expired, but the tokenable_verifier is missing in the JWT' do
    let(:verifier) { SecureRandom.hex }
    let(:user) { UserWithVerifier.create!(tokenable_verifier: verifier) }

    let(:jwt_data) do
      {
        exp: 1.minute.from_now.to_i,
        data: {
          user_id: user.id,
        },
      }
    end

    before do
      Tokenable::Config.user_class = UserWithVerifier
      request.headers['Authorization'] = "Bearer #{JWT.encode(jwt_data, Tokenable::Config.secret, "HS256")}"
    end

    it { is_expected.to raise_error(Tokenable::Unauthorized, 'Token verifier is invalid') }
  end

  describe 'when a valid JWT token is provided, and it has not expired, and the verifier is valid' do
    render_views

    let(:verifier) { SecureRandom.hex }
    let(:user) { UserWithVerifier.create!(tokenable_verifier: verifier) }

    let(:jwt_data) do
      {
        exp: 1.minute.from_now.to_i,
        data: {
          user_id: user.id,
          verifier: verifier,
        },
      }
    end

    before do
      Tokenable::Config.user_class = UserWithVerifier
      request.headers['Authorization'] = "Bearer #{JWT.encode(jwt_data, Tokenable::Config.secret, "HS256")}"
    end

    it 'gets the correct current_user' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(assigns[:user]).to eq(user)
      expect(assigns[:user]).to be_a(Tokenable::Config.user_class)
    end
  end
end
