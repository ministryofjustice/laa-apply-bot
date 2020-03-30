require 'spec_helper'
require 'rack/test'

describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    App.new
  end

  it 'displays home page' do
    get '/'
    expect(last_response.body).to include('LAA-Apply bot')
  end
end
