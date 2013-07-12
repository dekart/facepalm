Rails.application.routes.draw do
  get '/facepalm/endpoint' => 'facepalm/endpoint#show', :as => :facepalm_endpoint
end
