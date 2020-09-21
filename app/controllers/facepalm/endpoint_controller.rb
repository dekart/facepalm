module Facepalm
  class EndpointController < ActionController::Base
    # OAuth 2.0 endpoint action added to ApplicationController and mounted to /facebook_oauth
    def show
      if params[:error]
        raise Facepalm::OAuthException.new(params[:error_description])
      else
        # this is where you get a code for requesting an access_token to do additional OAuth requests
        # outside of using the FB JavaScript library (see Authenticating Users in a Web Application
        # under the Authentication docs at http://developers.facebook.com/docs/authentication/)
        if params[:code]
          begin
            return_to = params[:state].gsub(/}|{/, '').split("fb_return_to=").last.to_s

            # Decrypting return URL and redirecting to it
            redirect_to(
              facebook_canvas_page_url + facepalm_url_encryptor.decrypt_and_verify(return_to)
            )
          rescue ActiveSupport::MessageEncryptor::InvalidMessage
            ::Rails.logger.fatal "Failed to decrypt return URL: #{ return_to }"

            redirect_to facebook_canvas_page_url
          end

          false
        else
          raise Facepalm::OAuthException.new('No code returned.')
        end
      end
    end
  end
end
