module Facepalm
  # Facebook application configuration class
  class Config
    attr_accessor :config

    class << self
      # A shortcut to access default configuration stored in RAILS_ROOT/config/facebook.yml
      def default
        @@default ||= self.new(load_default_config_from_file)
      end

      def load_default_config_from_file
        config_data = YAML.load(
          ERB.new(
            File.read(::Rails.root.join("config", "facebook.yml"))
          ).result
        )[::Rails.env]

        raise NotConfigured.new("Unable to load configuration for #{ ::Rails.env } from config/facebook.yml") unless config_data

        config_data
      end
    end

    def initialize(options = {})
      self.config = options.to_options
    end

    # Defining methods for quick access to config values
    %w{app_id secret namespace callback_domain}.each do |attribute|
      class_eval %{
        def #{ attribute }
          config[:#{ attribute }]
        end
      }
    end

    def oauth_client
      @oauth_client ||= Koala::Facebook::OAuth.new(app_id, secret)
    end

    # Koala Facebook API client instantiated with application access token
    def api_client
      @api_client ||= Koala::Facebook::API.new(app_access_token)
    end

    # Fetches application access token
    def app_access_token
      @app_access_token ||= oauth_client.get_app_access_token
    end

    def subscription_token
      Digest::MD5.hexdigest(secret)
    end

    # URL of the application canvas page
    def canvas_page_url(protocol)
      "#{ protocol }apps.facebook.com/#{ namespace }"
    end

    # Application callback URL
    def callback_url(protocol)
      protocol + callback_domain
    end
  end
end