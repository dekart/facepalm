module Facepalm
  module Rails
    module Controller
      def self.included(base)
        base.class_eval do
          include Facepalm::Rails::Controller::OauthAccess
          include Facepalm::Rails::Controller::UrlRewriting
          include Facepalm::Rails::Controller::Redirects

          before_filter :normal_cookies_for_ie_in_iframes!

          helper_method(:facepalm, :fb_signed_request, :current_facebook_user, :params_without_facebook_data)
        end
      end

      def facepalm
        Facepalm::Config.default
      end

      def current_facebook_user
        @current_facebook_user ||= fetch_current_facebook_user
      end

      def fetch_current_facebook_user
        Facepalm::User.from_signed_request(facepalm, fb_signed_request || fb_cookie)
      end

      def fb_cookie
        cookies["fbsr_#{ facepalm.app_id }"]
      end

      def fb_signed_request
        request.env['HTTP_SIGNED_REQUEST'] || flash[:signed_request]
      end

      def params_without_facebook_data
        params.except(:signed_request)
      end
    end
  end
end