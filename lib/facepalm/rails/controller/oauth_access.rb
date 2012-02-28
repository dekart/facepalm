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
          end
        end

        protected

        # Requires a given set of permissions in context of the current action.
        # Use it to require permissions in a single action or custom filter.
        #
        # NOTE: Facepalm doesn't check if user provided all required permissions.
        #       It only checks if user was authenticated and redirects to permission
        #       request page with a given set of permissions.
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
            redirect_from_iframe(
              facepalm.oauth_client.url_for_oauth_code(
                :permissions => permissions,
                :callback => facepalm_endpoint_url(
                  :fb_return_to => ::Rack::Utils.escape(facepalm_auth_return_code)
                )
              )
            )

            false
          end
        end
        
        # Encrypting return URL to pass it to Facebook
        def facepalm_auth_return_code
          facepalm_url_encryptor.encrypt(
              url_for(params_without_facebook_data.merge(:canvas => false, :only_path => true))
            )
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