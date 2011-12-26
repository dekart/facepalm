ActionController::Routing::Routes.draw do |map|

  # OAuth 2.0 endpoint for facebook authentication
  map.facepalm_oauth_endpoint '/facebook_oauth',
    :controller => :application,
    :action     => :facepalm_oauth_endpoint

end