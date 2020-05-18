require 'spec_helper'
require 'rack/test'

describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    App.new
  end

  it 'displays home page' do
    get '/'
    expect(last_response.body).to include('LAA-Apply bot')
  end

  describe '/2fa/:token' do
    before { get "/2fa/#{token}" }

    context 'when token is not base64 encoded' do
      let(:token) { 'invalid' }

      it 'returns an unprocessable entity error' do
        expect(last_response.status).to eq 422
      end
    end

    context 'when the token is valid' do
      let(:token) { TokenGenerator.call('test_user_name') }

      it 'returns a 200 code' do
        expect(last_response.status).to eq 200
      end

      it 'displays the correct text' do
        expect(last_response.body).to include('Your 2FA QR code')
      end
    end

    context 'when the token was generated 15 minutes ago' do
      let(:token) { Timecop.travel(Time.now - (15 * 60)) { TokenGenerator.call('test_user_name') } }

      it 'returns a 403 code' do
        expect(last_response.status).to eq 403
      end
    end

    context 'when the secrets do not match' do
      let(:token) do
        token = { slack_id: 'leet_haxxor', expires_at: Time.now + (10 * 60), secret: 'attempt-to-hack-slack-bot' }
        Base64.urlsafe_encode64(token.to_json)
      end

      it 'returns a 403 code' do
        expect(last_response.status).to eq 403
      end
    end
  end
end
