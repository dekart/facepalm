require 'facepalm/rails/helpers/url_helper'

module Facepalm
  module Rails
    module Controller
      module UrlRewriting
        include Facepalm::Rails::Helpers::UrlHelper

        def self.included(base)
          base.class_eval do
            helper_method(:facebook_canvas_page_url, :facebook_callback_url)
          end
        end

        protected

        # A helper to generate an URL of the application canvas page URL
        #
        # @param protocol A request protocol, should be either 'http://' or 'https://'.
        #                 Defaults to current protocol.
        def facebook_canvas_page_url(protocol = nil)
          facepalm.canvas_page_url(protocol || request.protocol)
        end

        # A helper to generate an application callback URL
        #
        # @param protocol A request protocol, should be either 'http://' or 'https://'.
        #                 Defaults to current protocol.
        def facebook_callback_url(protocol = nil)
          facepalm.callback_url(protocol || request.protocol)
        end
      end
    end
  end
end
