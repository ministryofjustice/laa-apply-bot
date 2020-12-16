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

  describe '#ping' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('BUILD_DATE').and_return(build_date)
      allow(ENV).to receive(:[]).with('BUILD_TAG').and_return(build_tag)
      get '/ping'
    end
    let(:build_date) { nil }
    let(:build_tag) { nil }

    context 'when environment variables set' do
      let(:build_date) { '20150721' }
      let(:build_tag) { 'test' }

      let(:expected_json) do
        {
          'build_date' => '20150721',
          'build_tag' => 'test'
        }
      end

      it 'returns JSON with app information' do
        expect(JSON.parse(last_response.body)).to eq(expected_json)
      end
    end

    context 'when environment variables not set' do
      it 'returns "Not Available"' do
        expect(JSON.parse(last_response.body).values).to be_all('Not Available')
      end
    end

    it 'returns ok http status' do
      expect(last_response.status).to eq 200
    end
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
