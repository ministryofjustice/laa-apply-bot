module SlackApplybot
  class Bot < SlackRubyBot::Bot
    help do
      title 'LAA Apply Bot'
      desc 'This bot assists the LAA Apply team to administer their applications'

      command 'details' do
        desc '`apply-bot <application> details <environment>` e.g. `apply-bot cfe details staging`'
        long_desc 'Shows the ping details page for the selected application and non-uat environments, '\
                  'e.g.  `apply-bot apply details staging` or `apply-bot cfe details production`'
      end
    end
  end
end
