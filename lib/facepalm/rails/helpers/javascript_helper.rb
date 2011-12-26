module Facepalm
  module Rails
    module Helpers
      module JavascriptHelper
        def fb_connect_js(*args, &block)
          options = args.extract_options!

          app_id  = args.shift || facepalm.app_id

          options.reverse_merge!(
            :cookie   => true,
            :status   => true,
            :xfbml    => true,
            :oauth    => true,
            :frictionless_requests => :true,
            :locale   => "en_US"
          )

          extra_js = capture(&block) if block_given?

          init_js = <<-JAVASCRIPT
            FB.init({
              appId  : '#{app_id}',
              status : #{ options[:status] }, // check login status
              cookie : #{ options[:cookie] }, // enable cookies to allow the server to access the session
              xfbml  : #{ options[:xfbml] },  // parse XFBML
              oauth  : #{ options[:oauth] },
              frictionlessRequests : #{ options[:frictionless_requests] },
              channelUrl : '#{ options[:channel_url] || 'null' }'
            });
          JAVASCRIPT
          init_js = "FB._https = true; #{ init_js }" if request.ssl?

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

          js = js.html_safe

          if block_given? && ::Rails::VERSION::STRING.to_i < 3
            concat(js)
          else
            js
          end
        end
      end
    end
  end
end
