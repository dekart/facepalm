module Facepalm
  module Rails

    # Rails application controller extension
    module Controller
      def self.included(base)
        base.class_eval do
          include Facepalm::Rails::Controller::OauthAccess
          include Facepalm::Rails::Controller::UrlRewriting
          include Facepalm::Rails::Controller::Redirects

          # Fix cookie permission issue in IE
          before_filter :normal_cookies_for_ie_in_iframes!

          helper_method(:facepalm, :fb_signed_request, :current_facebook_user, :params_without_facebook_data)
        end
      end

      # Accessor to current application config. Override it in your controller
      # if you need multi-application support or per-request configuration selection.
      def facepalm
        Facepalm::Config.default
      end

      # Accessor to current facebook user. Returns instance of Facepalm::User
      def current_facebook_user
        @current_facebook_user ||= fetch_current_facebook_user
      end

      # Accessor to secure cookie set by Facebook
      def fb_cookie
        cookies["fbsr_#{ facepalm.app_id }"]
      end

      # Accessor to signed request passed either in params or in flash
      def fb_signed_request
        request.env['HTTP_SIGNED_REQUEST'] || flash[:signed_request]
      end

      # A hash of params passed to this action, excluding secure information 
      # passed by Facebook
      def params_without_facebook_data
        params.except(:signed_request)
      end

      private

      def fetch_current_facebook_user
        Facepalm::User.from_signed_request(facepalm, fb_signed_request || fb_cookie)
      end
    end

  end
end