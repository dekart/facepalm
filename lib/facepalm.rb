module Facepalm
end

# Dependencies
require 'koala'

require 'facepalm/config'
require 'facepalm/user'

require 'facepalm/rack/post_canvas_middleware'

# Rails integration
require 'facepalm/rails/controller'
require 'facepalm/rails/helpers'

require 'facepalm/engine'
require 'facepalm/routes'