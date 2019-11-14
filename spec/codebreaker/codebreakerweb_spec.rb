require 'spec_helper'

RSpec.describe CodebreakerWeb do
  let(:app) { Rack::Builder.parse_file('config.ru').first }
  let(:game) { Codebreaker::Game.new }

  context 'statuses' do

    it 'returns status page not found' do
      get '/unknown'
      expect(last_response.body).to include('Page Not Found')
    end

    it 'menu - returns status ok' do
      get '/'
      expect(last_response).to be_ok
    end

    it 'statistics - returns status ok' do
      get '/statistics'
      expect(last_response).to be_ok
    end

    it 'win - returns status ok' do
      get '/win'
      expect(last_response).to be_ok
    end

    it 'lose - returns status ok' do
      get '/lose'
      expect(last_response).to be_ok
    end

    it 'rules - returns status ok' do
      get '/rules'
      expect(last_response).to be_ok
    end
  end

  context 'cookies' do
    it 'sets cookies' do
      set_cookie('user_id=123')
      get '/'
      expect(last_request.cookies).to eq({"user_id"=>"123"})
    end
  end

  context 'redirects' do
    let(:name) { 'Adam' }
    let(:difficulty) { Codebreaker::Game::DIFFICULTY.dig(:easy, :mode) }

    before do
      post '/game', player_name: name, level: difficulty
    end
    it 'to game page' do
      post '/game'
      expect(last_response).to be_redirect
      expect(last_response.body["game"]).to eq('/game')
    end
  end

end