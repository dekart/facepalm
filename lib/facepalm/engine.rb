if Rails::VERSION::MAJOR > 2

  module Facepalm
    class Engine < ::Rails::Engine
      initializer "facepalm.middleware" do |app|
        app.middleware.insert_after(ActionDispatch::ParamsParser, Facepalm::Rack::PostCanvasMiddleware)
      end

      initializer "facepalm.controller_extension" do
        ActiveSupport.on_load :action_controller do
          ActionController::Base.send(:include, Facepalm::Rails::Controller)
        end
      end
    end
  end

else
  ActionController::Routing::Routes.add_configuration_file(File.expand_path('../../../config/routes.rb', __FILE__))

  ActionController::Dispatcher.middleware.insert_after(ActionController::ParamsParser, Facepalm::Rack::PostCanvasMiddleware)

  ActionController::Base.send(:include, Facepalm::Rails::Controller)

  # Loading plugin controllers manually because the're not loaded automatically from gems
  Dir[File.expand_path('../../../app/controllers/**/*.rb', __FILE__)].each do |file|
    require file
  end
end
