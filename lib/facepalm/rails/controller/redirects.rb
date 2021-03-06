module Facepalm
  module Rails
    module Controller
      module Redirects
        def self.included(base)
          base.class_eval do
            alias_method :redirect_to_without_signed_request, :redirect_to
            alias_method :redirect_to, :redirect_to_with_signed_request
          end
        end

        protected

        # Overrides ActionController::Base#redirect_to to pass signed_request in flash[]
        def redirect_to_with_signed_request(*args)
          flash[:signed_request] = fb_signed_request if fb_canvas?

          redirect_to_without_signed_request(*args)
        end

        # Redirects user to a definite URL with JavaScript code that overwrites
        # top frame location. Use it to redirect user from within an iframe.
        def redirect_from_iframe(url_options)
          redirect_url = url_options.is_a?(String) ? url_options : url_for(url_options)

          logger.info "Redirecting from IFRAME to #{ redirect_url }"

          respond_to do |format|
            format.html do
              render(
                :plain   => iframe_redirect_html_code(redirect_url),
                :layout => false
              )
            end

            format.js do
              render(
                :plain   => iframe_redirect_js_code(redirect_url),
                :layout => false
              )
            end
          end
        end

        # Generates HTML and JavaScript code to redirect user with top frame location
        # overwrite
        #
        # @param target_url   An URL to redirect the user to
        # @param custom_code  A custom HTML code to insert into the result document.
        #                     Can be used to add OpenGraph tags to redirect page code.
        def iframe_redirect_html_code(target_url, custom_code = nil)
          %{
            <html>
              <head>
                <meta http-equiv="content-type" content="text/html; charset=utf-8">
                <script type="text/javascript">
                  #{ iframe_redirect_js_code(target_url) };
                </script>
                #{ custom_code }
              </head>
              <body>
                <noscript>
                  <meta http-equiv="refresh" content="0;url=#{ target_url }" />
                  <meta http-equiv="window-target" content="_top" />
                </noscript>
              </body>
            </html>
          }
        end

        # Generates JavaScript code to redirect user
        #
        # @param target_url   An URL to redirect the user to
        def iframe_redirect_js_code(target_url)
          "window.top.location.href = #{ target_url.to_json };"
        end
      end
    end
  end
end