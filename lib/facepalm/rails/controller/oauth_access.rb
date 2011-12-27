module Facepalm
  class OAuthException < StandardError; end

  module Rails
    module Controller

      # OAuth 2.0 authentication module
      module OauthAccess
        def self.included(base)
          base.extend(ClassMethods)
        end

        # A filter class for Rails
        class AccessFilter
          def initialize(*permissions)
            @permissions = permissions
          end

          def filter(controller)
            controller.send(:facepalm_require_authentication, *@permissions)
          end
        end

        module ClassMethods
          # Requires Facebook authentication for the whole set of controller actions.
          # Use it to setup a given set of permissions for the whole controller
          #
          # @param permissions  An array of permissions to require
          # @param options      A hash of options to control filter application, similar to
          #                     options hash for before_filter
          #
          # @example
          #   class MyController < ApplicationController
          #     facepalm_authentication :email, :publish_actions, :only => :index
          #   end
          def facepalm_authentication(*permissions)
            options = permissions.extract_options!

            cattr_accessor :facepalm_authentication_filter
            self.facepalm_authentication_filter = AccessFilter.new(*permissions)

            before_filter(facepalm_authentication_filter, options)
            skip_before_filter(facepalm_authentication_filter, :only => :facepalm_oauth_endpoint)
          end
        end

        # Requires a given set of permissions in context of the current action.
        # Use it to require permissions in a single action or custom filter.
        #
        # @param permissions An array of permissions to require
        #
        # @return true if user authorized the application, false otehrwise
        #
        # @example
        #   class MyController < ApplicationController
        #     before_filter :my_custom_filter, :only => :show
        #
        #     def my_custom_filter
        #       my_custom_condition? and facepalm_require_authentication(:publish_actions)
        #     end
        #
        #     def index
        #       if facepalm_require_authentication(:email)
        #         ... do what you need ...
        #       end
        #     end
        #   end
        def facepalm_require_authentication(*permissions)
          if current_facebook_user.try(:authenticated?)
            true
          else
            # Encrypting return URL to pass it to Facebook
            return_code = facepalm_url_encryptor.encrypt(
              url_for(params_without_facebook_data.merge(:canvas => false, :only_path => true))
            )

            redirect_from_iframe(
              facepalm.oauth_client.url_for_oauth_code(
                :permissions => permissions,
                :callback => facepalm_oauth_endpoint_url(
                  :fb_return_to => ::Rack::Utils.escape(return_code)
                )
              )
            )

            false
          end
        end

        # OAuth 2.0 endpoint action added to ApplicationController and mounted to /facebook_oauth
        def facepalm_oauth_endpoint
          if params[:error]
            raise Facepalm::OAuthException.new(params[:error][:message])
          else
            # this is where you get a code for requesting an access_token to do additional OAuth requests
            # outside of using the FB JavaScript library (see Authenticating Users in a Web Application
            # under the Authentication docs at http://developers.facebook.com/docs/authentication/)
            if params[:code]
              begin
                # Decrypting return URL and redirecting to it
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

        # Internally used to encrypt return URL for authentication endpoint
        #
        # @return ActiveSupport::MessageEncryptor
        #
        # @private
        def facepalm_url_encryptor
          @facebook_url_encryptor ||= ActiveSupport::MessageEncryptor.new(facepalm.secret)
        end
      end
    end
  end
end