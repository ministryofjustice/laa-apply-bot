class BaseMessage
  private

  def service
    {
      apply: 'Apply',
      cfe: 'CFE',
      hmrc: 'HMRC',
      lfa: 'LFA'
    }[@service.downcase.to_sym]
  end

  def block(message)
    { 'type': 'section', 'text': { 'type': 'mrkdwn', 'text': message } }
  end

  def delete_block_with_button(branch_id)
    {
      'type': 'section',
      'block_id': "delete_branch|#{service.downcase}|#{branch_id}",
      'text': { 'type': 'mrkdwn', 'text': branch_id },
      'accessory': button(nil, "Delete #{branch_id}", branch_id, 'delete_branch')
    }
  end

  def button(style, text, value = nil, action_id = nil)
    base = {
      'type': 'button',
      'text': { 'type': 'plain_text', 'emoji': true, 'text': text.capitalize },
      'action_id': action_id || text.downcase.split.join('_')
    }
    base.merge!({ 'style': style }) unless style.nil?
    base.merge!({ 'value': value }) unless value.nil?
    base
  end
end
