class DateDisplay
  def self.call(date)
    new(date).call
  end

  def initialize(date)
    @date = date
  end

  def call
    count = (Date.today - @date).to_i
    case count
    when 0
      'today'
    when 1
      'yesterday'
    else
      "#{count} days ago"
    end
  end
end
