module ChannelValidity
  private

  def send_fail
    message_text = "Sorry <@#{@data.user}>, I don't understand that command!"
    @client.say(channel: @data.channel, text: message_text)
  end

  def channel_is_valid?
    @channel_info = SendSlackMessage.new.conversations_info(channel: @data.channel)
    return true if @channel_info['channel']['is_im']

    channel_name = @channel_info['channel']['name']
    return ENV['ALLOWED_CHANNEL_LIST'].include?(channel_name) if channel_name.present?
  rescue NoMethodError
    false
  end

  def user_is_valid?
    # current user is in applyprivatebeta
  end
end
