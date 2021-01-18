# frozen_string_literal: true

class UserWithSecurePasswordStrategy < User
  include Tokenable::Strategies::SecurePassword

  def authenticate(password); end
end

describe Tokenable::Strategies::SecurePassword do
  subject { UserWithSecurePasswordStrategy.from_tokenable_params(params) }

  before { Tokenable::Config.user_class = UserWithSecurePasswordStrategy }

  let(:password) { SecureRandom.hex }
  let(:user) { UserWithSecurePasswordStrategy.new(email: 'test@example.com') }
  let(:params) do
    ActionController::Parameters.new(email: user.email, password: password)
  end

  it 'returns nil when the email is incorrect' do
    expect(UserWithSecurePasswordStrategy).to receive(:find_by).with(email: user.email).and_return(nil)
    expect(user).not_to receive(:authenticate)
    expect(subject).to be_nil
  end

  it 'returns nil when the password is incorrect' do
    expect(UserWithSecurePasswordStrategy).to receive(:find_by).with(email: user.email).and_return(user)
    expect(user).to receive(:authenticate).with(password).and_return(false)
    expect(subject).to be_nil
  end

  it 'returns a user when the password is correct' do
    expect(UserWithSecurePasswordStrategy).to receive(:find_by).with(email: user.email).and_return(user)
    expect(user).to receive(:authenticate).with(password).and_return(true)
    expect(subject).to be(user)
  end
end
