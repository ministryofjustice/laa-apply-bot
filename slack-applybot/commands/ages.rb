module SlackApplybot
  module Commands
    class Ages < SlackRubyBot::Commands::Base
      command 'ages' do |client, data, _match|
        apply_message = age_message('Apply')
        cfe_message = age_message('CFE')
        # get master data from github?
        message_text = "#{apply_message}\n#{cfe_message}"
        client.say(channel: data.channel, text: message_text)
      end

      class << self
        private

        def age_message(app)
          application = Environment.new(app.downcase, 'production')
          deploy_date = Date.parse(application.ping_data['build_date'])
          "#{app} was deployed #{DateDisplay.call(deploy_date)}"
        end
      end
    end
  end
end
