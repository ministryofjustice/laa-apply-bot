module SlackApplybot
  module Commands
    class IntegrationTests < SlackRubyBot::Commands::Base
      command 'run tests' do |client, data, _match|
        client.typing(channel: data.channel)
        TestRunStartWorker.perform_async(data)
      end
    end
  end
end
