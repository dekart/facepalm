module Facepalm

  # A class for Facebook user
  class User
    class UnsupportedAlgorithm < StandardError; end
    class InvalidSignature < StandardError; end

    class << self
      # Creates an instance of Facepalm::User using application config and signed_request
      def from_signed_request(config, input)
        return if input.blank?

        new(parse_signed_request(config, input))
      end

      # Originally provided directly by Facebook, however this has changed
      # as their concept of crypto changed. For historic purposes, this is their proposal:
      # https://developers.facebook.com/docs/authentication/canvas/encryption_proposal/
      # Currently see https://github.com/facebook/php-sdk/blob/master/src/facebook.php#L758
      # for a more accurate reference implementation strategy.
      def parse_signed_request(config, input)
        encoded_sig, encoded_envelope = input.split('.', 2)
        signature = base64_url_decode(encoded_sig).unpack("H*").first

        MultiJson.decode(base64_url_decode(encoded_envelope)).tap do |envelope|
          raise UnsupportedAlgorithm.new("Unsupported encryption algorithm: #{ envelope['algorithm'] }") unless envelope['algorithm'] == 'HMAC-SHA256'

          # now see if the signature is valid (digest, key, data)
          hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, config.secret, encoded_envelope)

          raise InvalidSignature.new('Invalid request signature') if (signature != hmac)
        end
      end

      def base64_url_decode(str)
        str += '=' * (4 - str.length.modulo(4))

        Base64.decode64(str.tr('-_', '+/'))
      end
    end


    def initialize(options = {})
      @options = options
    end

    # Checks if user is authenticated in the application
    def authenticated?
      access_token && !access_token.empty?
    end

    # Facebook UID
    def uid
      @options['user_id']
    end

    # The code used for OAuth 2.0
    def oauth_code
      @options['code']
    end

    # OAuth 2.0 access token generated for this user
    def access_token
      @options['access_token'] || @options['oauth_token']
    end

    # Token expiration time
    def access_token_expires_at
      Time.at(@options['expires']) if @options['expires']
    end

    # Koala Facebook API client instantiated with user's access token
    def api_client
      @api_client ||= Koala::Facebook::API.new(access_token)
    end
  end

end