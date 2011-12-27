if Rails::VERSION::MAJOR < 3
  ActionController::Routing::Routes.draw do |map|

    # OAuth 2.0 endpoint for facebook authentication
    map.facepalm_endpoint '/facepalm/endpoint',
      :controller => "facepalm/endpoint",
      :action     => "show"

  end
else
  Rails.application.routes.draw do
    match '/facepalm/endpoint' => 'facepalm/endpoint#show', :as => :facepalm_endpoint
  end
end