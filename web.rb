require 'sinatra/base'

module SlackApplybot
  class Web < Sinatra::Base
    get '/' do
      'LAA-Apply bot, find it in slack'
    end
  end
end
