module UserCommand
  def user
    User.find_or_create_by(slack_id: @data.user)
  end
end
