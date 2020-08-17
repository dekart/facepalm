module Facepalm
  class Engine < ::Rails::Engine
    initializer "facepalm.middleware" do |app|
      app.middleware.use(Facepalm::Rack::PostCanvasMiddleware)
    end

    initializer "facepalm.controller_extension" do
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, Facepalm::Rails::Controller)
      end
    end
  end
end
