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
      post '/game', {player_name: name, level: difficulty}, { game: game }
    end

    ['menu', 'submit_answer', 'show_hints', 'statistics', 'win', 'lose', 'rules'].each do |element|

      it "#{element} - returns status ok" do
        get "/#{element}"
        expect(last_response).to be_ok
      end
    end
  end

  #   it 'submit_answer - returns status ok' do
  #     get '/submit_answer'
  #     expect(last_response).to be_ok
  #   end

  #   it 'show_hints - returns status ok' do
  #     get '/show_hints'
  #     expect(last_response).to be_ok
  #   end

  #   it 'statistics - returns status ok' do
  #     get '/statistics'
  #     expect(last_response).to be_ok
  #   end

  #   it 'win - returns status ok' do
  #     get '/win'
  #     expect(last_response).to be_ok
  #   end

  #   it 'lose - returns status ok' do
  #     get '/lose'
  #     expect(last_response).to be_ok
  #   end

  #   it 'rules - returns status ok' do
  #     get '/rules'
  #     expect(last_response).to be_ok
  #   end
  # end

  context 'cookies' do
    it 'sets cookies' do
      set_cookie('user_id=123')
      get '/'
      expect(last_request.cookies).to eq({"user_id"=>"123"})
    end
  end

  context 'redirects if session active' do
    it 'from rules to game page' do
      get '/rules'
      expect(last_response).to be_redirect
      expect(last_response.header["game"]).to eq('/game')
    end
  end

end