module SlackApplybot
  module Commands
    class Ages < SlackRubyBot::Commands::Base
      command 'ages' do |client, data, _match|
        apply = Environment.new('apply', 'production')
        apply_age = (Date.today - Date.parse(apply.ping_data['build_date'])).to_i
        cfe = Environment.new('cfe', 'production')
        cfe_age = (Date.today - Date.parse(cfe.ping_data['build_date'])).to_i
        # get master data from github?
        message_text = "#{age_message('Apply', apply_age)}\n#{age_message('CFE', cfe_age)}"
        client.say(channel: data.channel, text: message_text)
      end

      class << self
        private

        def age_message(app, age)
          "#{app} was deployed #{age} #{'day'.pluralize(age)} ago"
        end
      end
    end
  end
end
