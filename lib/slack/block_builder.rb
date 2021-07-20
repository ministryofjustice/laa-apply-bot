module Slack
  class BlockBuilder
    STATES = %i[start searching waiting complete error].freeze

    def self.start_error(message)
      new.call(:error, message: "Could not trigger job on Github ```#{message}```")
    end

    def self.timeout_error
      new.call(:error, message: ":nope: It's been over two minutes, you'll need to check github manually")
    end

    def self.call(state, **args)
      new.call(state, **args)
    end

    def call(state, **args)
      raise 'State error' unless STATES.include?(state)

      @args = args
      @block_id = state.to_s
      @message = args[:message] || send(state)
      {
        'blocks': [block]
      }
    end

    private

    def start
      ':spinner2: A test run has been requested from Github'
    end

    def searching
      ":spinner2: A test run has been requested from Github. Time spent looking so far: #{@args[:duration]}"
    end

    def waiting
      ":spinner2: The tests are running.\n"\
        " I'll update you on completion, or you can click on <#{@args[:web_url]}|this link> for details"
    end

    def complete
      result = @args[:result] ? 'Successfully' : 'Failed'
      icon = @args[:result] ? 'yep' : 'nope'
      "*Test run has completed*\n:#{icon}: <#{@args[:web_url]}|#{result}>"
    end

    def block
      {
        'type': 'section',
        'block_id': @block_id.to_s,
        'text': {
          'type': 'mrkdwn',
          'text': @message.to_s
        }
      }
    end
  end
end
