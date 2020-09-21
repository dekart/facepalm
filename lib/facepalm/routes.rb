module Facepalm
  module Routes
    def default_facepalm_endpoint
      get '/facepalm/endpoint' => 'facepalm/endpoint#show', :as => :facepalm_endpoint
    end
  end
end

ActionDispatch::Routing::Mapper.include(Facepalm::Routes)