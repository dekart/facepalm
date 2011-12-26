module Facepalm
  module Rack

    # This rack middleware converts POST requests from Facebook to GET requests.
    # It's necessary to make RESTful routes work as expected without any changes
    # in the application.
    class PostCanvasMiddleware
      def initialize(app, options = {})
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)

        if request.POST['signed_request'] && request.post? && request.params['_method'].blank?
          env['REQUEST_METHOD'] = 'GET'
        end

        # Put signed_request parameter to the same place where HTTP header X-Signed-Request come.
        # This let us work both with params and HTTP headers in the same way. Very useful for AJAX.
        env['HTTP_SIGNED_REQUEST'] ||= request.POST['signed_request']

        @app.call(env)
      end
    end

  end
end