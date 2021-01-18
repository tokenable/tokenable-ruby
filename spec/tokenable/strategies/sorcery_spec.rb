# frozen_string_literal: true

class UserWithSorceryStrategy < User
  include Tokenable::Strategies::Sorcery

  def valid_password?(password); end
end

describe Tokenable::Strategies::Sorcery do
  subject(:login) { UserWithSorceryStrategy.from_tokenable_params(params) }

  before { Tokenable::Config.user_class = UserWithSorceryStrategy }

  let(:password) { SecureRandom.hex }
  let(:user) { UserWithSorceryStrategy.new(email: 'test@example.com') }
  let(:params) do
    ActionController::Parameters.new(email: user.email, password: password)
  end

  it 'returns nil when the email is incorrect' do
    expect(UserWithSorceryStrategy).to receive(:find_by).with(email: user.email).and_return(nil)
    expect(user).not_to receive(:valid_password?)
    expect(subject(:login)).to be_nil
  end

  it 'returns nil when the password is incorrect' do
    expect(UserWithSorceryStrategy).to receive(:find_by).with(email: user.email).and_return(user)
    expect(user).to receive(:valid_password?).with(password).and_return(false)
    expect(subject(:login)).to be_nil
  end

  it 'returns a user when the password is correct' do
    expect(UserWithSorceryStrategy).to receive(:find_by).with(email: user.email).and_return(user)
    expect(user).to receive(:valid_password?).with(password).and_return(true)
    expect(subject(:login)).to be(user)
  end
end
