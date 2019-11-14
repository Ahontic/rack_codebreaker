require 'pry'
require 'codebreaker'

class CodebreakerWeb
  include ::Codebreaker::Storage
  attr_accessor :game, :hints_presenter

  VIEWS = {
    menu: 'menu.html',
    game: 'game.html',
    win: 'win.html',
    lose: 'lose.html',
    statistics: 'statistics.html',
    rules: 'rules.html',
    error: '404.html'
  }.freeze

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    load_session if session_present?
    case @request.path
    when '/' then menu
    when '/game' then game
    when '/submit_answer' then submit_answer
    when '/win' then win
    when '/lose' then lose
    when '/statistics' then statistics
    when '/rules' then rules
    when '/show_hints' then show_hints
    else load_page(:error)
    end
  end

  def menu
    load_page(:menu)
  end

  def game
    game_cycle
    load_page(:game)
  end

  def submit_answer
    return load_page(:menu) unless session_present?

    game_round if @game.guess_valid?(user_guess)
    @game.attempt_used
    save_session
    return render_result if game_result?

    load_page(:game)
  end

  def game_result?
    @game.won?(@user_guess) || @game.lost?
  end

  def render_result
    session_clear[:player]
    return load_page(:lose, false) if @game.lost?

    save_result
    return load_page(:win, false) if @game.won?(@user_guess)
  end

  def win
    load_page(:win)
  end

  def lose
    load_page(:lose)
  end

  def statistics
    @statistics = load_database
    load_page(:statistics, false)
  end

  def rules
    load_page(:rules)
  end

  def load_page(page, session_required = true)
    page_to_render = session_present? && session_required ? VIEWS[:game] : VIEWS[page]
    Rack::Response.new(render(page_to_render))
  end

  def render(template)
    path = File.expand_path("../../app/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def user_guess
    @user_guess = @request.params['number']
  end

  def game_cycle
    game_start
    save_session
  end

  def show_hints
    @hints_presenter << @game.take_hint! if @game.hint_keeper.any?
    save_session
    load_page(VIEWS[:game])
  end

  def game_round
    @guess = @user_guess.chars.map(&:to_i)
    @game.guess(@guess)
  end

  def game_start
    @game = Codebreaker::Game.new
    binding.pry
    @game.set(@request.params['level'])
    @player = Codebreaker::Player.new
    @player.name = @request.params['player_name']
    @hints_presenter = []
  end

  def save_session
    @request.session[:hints_presenter] = @hints_presenter
    @request.session[:game] = @game
    @request.session[:player] = @player
  end

  def load_session
    @hints_presenter = @request.session[:hints_presenter]
    @game = @request.session[:game]
    @player = @request.session[:player]
  end

  def save_result
    @game.save(@game.to_yaml(@player.name))
  end

  def session_clear
    @request.session.clear
  end

  def session_present?
    @request.session.key?(:game)
  end
end
