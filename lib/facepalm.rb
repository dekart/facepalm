module Facepalm
end

# Dependencies
require 'ie_iframe_cookies'
require 'koala'

require 'facepalm/config'
require 'facepalm/user'

require 'facepalm/rack/post_canvas_middleware'

# Rails integration
require 'facepalm/rails/controller'
require 'facepalm/rails/helpers'

if Rails::VERSION::MAJOR > 2
  require 'facepalm/engine'
else
  ActionController::Dispatcher.middleware.insert_after(ActionController::ParamsParser, Facepalm::Rack::PostCanvasMiddleware)
end

