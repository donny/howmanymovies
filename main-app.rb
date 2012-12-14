require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'tzinfo'
require 'cgi'
require 'httparty'
require 'json'

configure :production do
  # Configure stuff here you'll want to only be run at Heroku at boot.
  # TIP:  You can get you database information
  #       from ENV['DATABASE_URI'] (see /env route below)
end

helpers do
  def get_films(name)
      query = [{'film' => [], 'name' => name, 'type' => '/film/director'}]
      query_envelope = {'query' => query }
      service_url = 'http://api.freebase.com/api/service/mqlread'
      url = service_url + '?query=' + CGI::escape(query_envelope.to_json)

      response = HTTParty.get(url, :format => :json)

      result = response['result']
      if (result.length == 0)
          films = []
      else
          films = result[0]['film']
      end
  end
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

not_found do
  haml :notfound
end

error do
  haml :error
end

post '/' do
  name = params[:name]

  @films = get_films(name)
  @name = name

  haml :index
end
 
get '/' do
  @films = get_films('Wes Anderson')
  @name = 'Wes Anderson'

  haml :index
end
