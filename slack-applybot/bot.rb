module SlackApplybot
  class Bot < SlackRubyBot::Bot
    help do
      title 'LAA Apply Bot'
      desc 'This bot assists the LAA Apply team to administer their applications'

      command 'ages' do
        desc '`@apply-bot ages`'
        long_desc 'Shows the time since both applications were last deployed'
      end

      command 'details' do
        desc '`@apply-bot <application> details <environment>` e.g. `@apply-bot cfe details staging`'
        long_desc 'Shows the ping details page for the selected application and non-uat environments, '\
                  'e.g.  `@apply-bot apply details staging` or `@apply-bot cfe details production`'
      end

      command 'run tests' do
        desc '`@apply-bot run tests`'
        long_desc 'Starts a remote test run on the linked github repo it will respond to you with a link '\
                  'to the running job on github.  When the job finishes it will message you with the result'
      end

      command 'uat urls' do
        desc '`@apply-bot uat urls`'
        long_desc 'Returns a list of all Apply UAT urls currently available'
      end

      command 'uat url' do
        desc '`@apply-bot uat url <branch> e.g. @apply-bot uat url ap-999`'
        long_desc 'This will either show the uat url for the specified branch or, if it cannot be matched,'\
                  'return an apology and the list of all available uat environments'
      end
    end
  end
end
