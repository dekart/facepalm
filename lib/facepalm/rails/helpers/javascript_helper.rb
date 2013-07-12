module Facepalm
  module Rails
    module Helpers
      module JavascriptHelper

        # A helper to integrate Facebook Connect to the current page. Generates a
        # JavaScript code that initializes Facebook Javascript client for the
        # current application.
        #
        # @param app_id   Facebook App ID of the application. Defaults to value provided by the current config.
        # @param options  A hash of options for JavaScript generation. Available options are:
        #                   :cookie - Enable cookie generation for the application. Default to true.
        #                   :status - Enable login status check. Defaults to true.
        #                   :xfbml - Enable XFBML tag parsing. Default to true.
        #                   :frictionless - Enable frictionless app request delivery. Defaults to true
        #                   :locale - Locale to use for JavaScript client. Defaults to 'en_US'.
        #                   :weak_cache - Enable FB JS client cache expiration every minute. Defaults to false.
        #                   :async - Enable asynchronous FB JS client code load and initialization. Defaults to false.
        #                   :cache_url - An URL to load custom or cached version of the FB JS client code. Not used by default.
        # @param &block   A block of JS code to be inserted in addition to FB client initialization code.
        def fb_connect_js(*args, &block)
          options = args.extract_options!

          app_id  = args.shift || facepalm.app_id

          options.reverse_merge!(
            :cookie       => true,
            :status       => true,
            :xfbml        => true,
            :frictionless => true,
            :locale       => "en_US"
          )

          extra_js = capture(&block) if block_given?

          init_js = <<-JAVASCRIPT
            FB.init({
              appId  : '#{ app_id }',
              status : #{ options[:status] },
              cookie : #{ options[:cookie] },
              xfbml  : #{ options[:xfbml] },
              frictionlessRequests : #{ options[:frictionless] },
              channelUrl : '#{ options[:channel_url] || 'null' }'
            });
          JAVASCRIPT

          js_url = "connect.facebook.net/#{options[:locale]}/all.js"
          js_url << "?#{Time.now.change(:min => 0, :sec => 0, :usec => 0).to_i}" if options[:weak_cache]

          if options[:async]
            js = <<-JAVASCRIPT
              window.fbAsyncInit = function() {
                #{init_js}
                #{extra_js}
              };

              (function() {
                var e = document.createElement('script');
                e.src = document.location.protocol + '//#{ js_url }';
                e.async = true;
                document.getElementById('fb-root').appendChild(e);
              }());
            JAVASCRIPT

            js = <<-CODE
              <div id="fb-root"></div>
              <script type="text/javascript">#{ js }</script>
            CODE
          else
            js = <<-CODE
              <div id="fb-root"></div>
              <script src="#{ request.protocol }#{ js_url }" type="text/javascript"></script>
            CODE

            if options[:cache_url]
              js << <<-CODE
                <script type="text/javascript">
                  window.FB || document.write(unescape(\"%3Cscript src='#{ options[:cache_url] }' type='text/javascript'%3E%3C/script%3E\"));
                </script>
              CODE
            end

            js << <<-CODE
              <script type="text/javascript">
                if(typeof FB !== 'undefined'){
                  #{init_js}
                  #{extra_js}
                }
              </script>
            CODE
          end

          js.html_safe
        end
      end
    end
  end
end
