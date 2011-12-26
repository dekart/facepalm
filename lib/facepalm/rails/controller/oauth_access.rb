module Facepalm
  class OAuthException < StandardError; end

  module Rails
    module Controller
      module OauthAccess
        def self.included(base)
          base.extend(ClassMethods)
        end

        class AccessFilter
          def initialize(*permissions)
            @permissions = permissions
          end

          def filter(controller)
            controller.send(:facepalm_require_authentication, *@permissions)
          end
        end

        module ClassMethods
          def facepalm_authentication(*permissions)
            options = permissions.extract_options!

            cattr_accessor :facepalm_authentication_filter
            self.facepalm_authentication_filter = AccessFilter.new(*permissions)

            before_filter(facepalm_authentication_filter, options)
            skip_before_filter(facepalm_authentication_filter, :only => :facepalm_oauth_endpoint)
          end
        end

        def facepalm_require_authentication(*permissions)
          if current_facebook_user.try(:authenticated?)
            true
          else
            return_code = facepalm_url_encryptor.encrypt(
              url_for(params_without_facebook_data.merge(:canvas => false, :only_path => true))
            )

            redirect_from_iframe(
              facepalm.oauth_client.url_for_oauth_code(
                :permissions => permissions,
                :callback => facepalm_oauth_endpoint_url(
                  :fb_return_to => Rack::Utils.escape(return_code)
                )
              )
            )

            false
          end
        end

        def facepalm_oauth_endpoint
          if params[:error]
            raise Facepalm::OAuthException.new(params[:error][:message])
          else
            # this is where you get a code for requesting an access_token to do additional OAuth requests
            # outside of using the FB JavaScript library (see Authenticating Users in a Web Application
            # under the Authentication docs at http://developers.facebook.com/docs/authentication/)
            if params[:code]
              begin
                redirect_to(facebook_canvas_page_url + facepalm_url_encryptor.decrypt(params[:fb_return_to].to_s))
              rescue ActiveSupport::MessageEncryptor::InvalidMessage
                ::Rails.logger.fatal "Failed to decrypt return URL: #{ params[:fb_return_to] }"

                redirect_to facebook_canvas_page_url
              end

              false
            else
              raise Facepalm::OAuthException.new('No code returned.')
            end
          end
        end

        def facepalm_url_encryptor
          @facebook_url_encryptor ||= ActiveSupport::MessageEncryptor.new(facepalm.secret)
        end
      end
    end
  end
end