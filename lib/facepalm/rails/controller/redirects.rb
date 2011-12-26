module Facepalm
  module Rails
    module Controller
      module Redirects
        def redirect_to(*args)
          flash[:signed_request] = fb_signed_request

          super(*args)
        end

        def redirect_from_iframe(url_options)
          redirect_url = url_options.is_a?(String) ? url_options : url_for(url_options)

          logger.info "Redirecting from IFRAME to #{ redirect_url }"

          render(
            :text   => iframe_redirect_code(redirect_url),
            :layout => false
          )
        end

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