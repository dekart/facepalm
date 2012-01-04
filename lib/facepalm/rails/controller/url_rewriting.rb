module Facepalm
  module Rails
    module Controller
      module UrlRewriting
        def self.included(base)
          base.class_eval do
            alias_method_chain :url_for, :facepalm

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

        # Overrides ActionController::Base#urs_for to filter out secure Facebook params
        # and add Facebook Canvas URL if necessary
        def url_for_with_facepalm(options = {})
          if options.is_a?(Hash)
            if options.delete(:canvas) && !options[:host]
              options[:only_path] = true

              canvas = true
            else
              canvas = false
            end

            url = url_for_without_facepalm(options.except(:signed_request))

            canvas ? facebook_canvas_page_url + url : url
          else
            url_for_without_facepalm(options)
          end
        end
      end
    end
  end
end