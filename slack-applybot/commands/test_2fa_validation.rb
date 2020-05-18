module SlackApplybot
  module Commands
    class Test2faValidation < SlackRubyBot::Commands::Base
      require 'rotp'
      require 'rqrcode'

      command '2fa-check' do |client, data, match|
        totp = ROTP::TOTP.new(ROTP::Base32.encode(data['user']), issuer: ENV.fetch('SERVICE_NAME'))
        validation_succeeded = totp.verify(match['expression']).present? ? 'successfully' : 'not'
        client.say(channel: data.channel, text: "2FA #{validation_succeeded} configured")
      end

      command '2fa-start' do |client, data, _match|
        token = TokenGenerator.call(data['user'])
        message_text = File.join(ENV.fetch('ROOT_URL'), '/2fa/', token)
        client.say(channel: data.channel, text: message_text)
      end
    end
  end
end
