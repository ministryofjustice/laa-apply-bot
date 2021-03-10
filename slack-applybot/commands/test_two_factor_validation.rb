module SlackApplybot
  module Commands
    class TestTwoFactorValidation < SlackRubyBot::Commands::Base
      require 'rotp'
      require 'rqrcode'

      command '2fa-start' do |client, data, _match|
        @client = client
        @data = data
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        client.typing(channel: data.channel)
        token = TokenGenerator.call(data.user)
        channel = data.channel
        if channel_is_not_dm?
          message_text = "I've sent you a DM, we probably shouldn't be talking about this in public!"
          client.say(channel: channel, text: message_text)
          channel = client.web_client.conversations_open(users: data['user'])['channel']['id']
        end

        SendSlackMessage.new.upload_file(
          channels: channel,
          as_user: true,
          file: Faraday::FilePart.new(StringIO.new(build_qr_code(token)), 'image/png'),
          title: 'Your apply-bot QR',
          initial_comment: 'Scan with an authenticator app'
        )
      end

      command '2fa-check' do |client, data, match|
        @client = client
        @data = data
        if channel_is_valid?
          totp = ROTP::TOTP.new(ROTP::Base32.encode(data['user']), issuer: ENV.fetch('SERVICE_NAME'))
          validation_succeeded = totp.verify(match['expression']).present? ? 'successfully' : 'not'
          client.say(channel: data.channel, text: "2FA #{validation_succeeded} configured")
        else
          send_fail
        end
      end

      class << self
        include ChannelValidity

        def build_qr_code(token)
          values = JSON.parse(Base64.urlsafe_decode64(token), object_class: OpenStruct)
          totp = ROTP::TOTP.new(ROTP::Base32.encode(values.slack_id), issuer: ENV.fetch('SERVICE_NAME'))
          qrcode = RQRCode::QRCode.new(totp.provisioning_uri(ENV.fetch('SERVICE_EMAIL')))

          qrcode.as_svg(
            offset: 10,
            shape_rendering: 'crispEdges',
            module_size: 6,
            standalone: true
          )
        end
      end
    end
  end
end
