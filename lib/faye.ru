require 'faye'

require File.expand_path('../faye_token.rb', __FILE__)

Faye::WebSocket.load_adapter('thin')

# app = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
#
# thin = Rack::Handler.get('thin')
#
# thin.run(app, :Port => 9292) do |server|
#   # You can set options on the server here, for example to set up SSL:
#   server.ssl_options = {
#       'ssl-key-file' => '/opt/nginx/ssl/nginx.key',
#       'ssl-cert-file'  => '/opt/nginx/ssl/nginx.pem'
#   }
#   server.ssl = true
# end

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if message['ext']['auth_token'] != FAYE_TOKEN
        message['error'] = 'Invalid authentication token'
      end
    end
    callback.call(message)
  end

  # IMPORTANT: clear out the auth token so it is not leaked to the client
  def outgoing(message, callback)
    if message['ext'] && message['ext']['auth_token']
      message['ext'] = {}
    end
    callback.call(message)
  end
end

# faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
# #faye_server.add_extension(ServerAuth.new)
# run faye_server

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)

thin = Rack::Handler.get('thin')
thin.run(faye_server, :Port => 9292) do |server|
#  You can set options on the server here, for example to set up SSL:
#   server.ssl_options = {
#       'ssl-key-file' => '/opt/nginx/ssl/nginx.key',
#       'ssl-cert-file'  => '/opt/nginx/ssl/nginx.pem'
#   }
#   server.ssl = true
end

