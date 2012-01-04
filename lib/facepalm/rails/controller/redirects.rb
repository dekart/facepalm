module Facepalm
  module Rails
    module Controller
      module Redirects
        def self.included(base)
          base.class_eval do
            alias_method_chain :redirect_to, :signed_request
          end
        end

        # Overrides ActionController::Base#redirect_to to pass signed_request in flash[]
        def redirect_to_with_signed_request(*args)
          flash[:signed_request] = fb_signed_request

          redirect_to_without_signed_request(*args)
        end

        # Redirects user to a definite URL with JavaScript code that overwrites
        # top frame location. Use it to redirect user from within an iframe.
        def redirect_from_iframe(url_options)
          redirect_url = url_options.is_a?(String) ? url_options : url_for(url_options)

          logger.info "Redirecting from IFRAME to #{ redirect_url }"

          render(
            :text   => iframe_redirect_code(redirect_url),
            :layout => false
          )
        end

        # Generates HTML and JavaScript code to redirect user with top frame location
        # overwrite
        #
        # @param target_url   An URL to redirect the user to
        # @param custom_code  A custom HTML code to insert into the result document.
        #                     Can be used to add OpenGraph tags to redirect page code.
        def iframe_redirect_code(target_url, custom_code = nil)
          %{
            <html><head>
              <script type="text/javascript">
                window.top.location.href = #{ target_url.to_json };
              </script>
              <noscript>
                <meta http-equiv="refresh" content="0;url=#{ target_url }" />
                <meta http-equiv="window-target" content="_top" />
              </noscript>
              #{ custom_code }
            </head></html>
          }
        end
      end
    end
  end
end