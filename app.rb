require 'sinatra'
require 'json'
require 'logger'
require 'le'

local =
  if settings.environment == :development
    "#{settings.root}/log/#{settings.environment}.log"
  else
    false
  end

set :logentries, Le.new(ENV['LOGENTRIES_TOKEN'], debug: true, local: local)

before do
  env["rack.logger"] = settings.logentries

  query = env["QUERY_STRING"]
  msg   = format("%s %s for %s",
                 env["REQUEST_METHOD"],
                 env["PATH_INFO"] + (query.empty? ? "" : "?#{query}"),
                 (env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-"))

  logger.info(msg)
end

get '/' do
  erb :index
end

post '/update' do
  request.body.rewind
  logger.info(JSON.parse(request.body.read))

  json_response 200
end

get '/target/:id' do
  logger.info(request.env)
  logger.info(request.referer)

  json_response 200, 'order.json'
end

private

def json_response(response_code, file_name = nil)
  content_type :json
  status response_code

  if file_name
    File.open(File.join(settings.root, 'fixtures', file_name), 'rb').read
  end
end
