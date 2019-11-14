require './lib/codebreakerweb.rb'

use Rack::Reloader
use Rack::Static, :urls => ['/assets'], :root => 'app', 'db'
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'my_secret'
run CodebreakerWeb