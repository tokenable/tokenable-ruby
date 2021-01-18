# frozen_string_literal: true

class UserWithDeviseStrategy < User
  include Tokenable::Strategies::Devise

  def valid_password?(password); end
end

describe Tokenable::Strategies::Devise do
  subject(:login) { UserWithDeviseStrategy.from_tokenable_params(params) }

  before { Tokenable::Config.user_class = UserWithDeviseStrategy }

  let(:password) { SecureRandom.hex }
  let(:user) { UserWithDeviseStrategy.new(email: 'test@example.com') }
  let(:params) do
    ActionController::Parameters.new(email: user.email, password: password)
  end

  it 'returns nil when the email is incorrect' do
    expect(UserWithDeviseStrategy).to receive(:find_by).with(email: user.email).and_return(nil)
    expect(user).not_to receive(:valid_password?)
    expect(subject(:login)).to be_nil
  end

  it 'returns nil when the password is incorrect' do
    expect(UserWithDeviseStrategy).to receive(:find_by).with(email: user.email).and_return(user)
    expect(user).to receive(:valid_password?).with(password).and_return(false)
    expect(subject(:login)).to be_nil
  end

  it 'returns a user when the password is correct' do
    expect(UserWithDeviseStrategy).to receive(:find_by).with(email: user.email).and_return(user)
    expect(user).to receive(:valid_password?).with(password).and_return(true)
    expect(subject(:login)).to be(user)
  end
end
