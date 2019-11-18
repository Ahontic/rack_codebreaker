# frozen_string_literal: true

RSpec.describe CodebreakerWeb do
  let(:app) { Rack::Builder.parse_file('config.ru').first }
  let(:game) { Codebreaker::Game.new }
  let(:difficulty) { 'easy' }
  let(:name) { 'Adam' }

  describe '404 - Not Found' do
    it 'returns status page not found' do
      get '/unknown'
      expect(last_response.body).to include('Page Not Found')
    end
  end
  context 'statuses - ok' do
    before do
      post '/game', { player_name: name, level: difficulty }, game: game
    end

    %w[menu submit_answer show_hints statistics win lose rules].each do |element|
      it "#{element} - returns status ok" do
        get "/#{element}"
        expect(last_response).to be_ok
      end
    end
  end

  context 'cookies' do
    it 'sets cookies' do
      set_cookie('user_id=123')
      get '/'
      expect(last_request.cookies).to eq('user_id' => '123')
    end
  end

  context 'redirects if session active' do
    before do
      post '/game', { player_name: name, level: difficulty }, game: game
    end
    it 'from rules to game page' do
      get '/rules'
      expect(last_response).to be_redirect
      expect(last_response.body['Submit']).to eq('/game')
    end
  end
end
