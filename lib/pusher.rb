autoload 'Logger', 'logger'
require 'uri'
require 'forwardable'

require 'pusher/client'

# Used for configuring API credentials and creating Channel objects
#
module Pusher
  # All errors descend from this class so they can be easily rescued
  #
  # @example
  #   begin
  #     Pusher.trigger('channel_name', 'event_name, {:some => 'data'})
  #   rescue Pusher::Error => e
  #     # Do something on error
  #   end
  class Error < RuntimeError; end
  class AuthenticationError < Error; end
  class ConfigurationError < Error; end
  class HTTPError < Error; attr_accessor :original_error; end

  class << self
    extend Forwardable

    def_delegators :default_client, :scheme, :host, :port, :app_id, :key, :secret, :http_proxy
    def_delegators :default_client, :scheme=, :host=, :port=, :app_id=, :key=, :secret=, :http_proxy=

    def_delegators :default_client, :authentication_token, :url
    def_delegators :default_client, :encrypted=, :url=

    def_delegators :default_client, :get, :get_async, :post, :post_async
    def_delegators :default_client, :channels, :channel_info, :trigger, :trigger_async
    def_delegators :default_client, :webhook, :channel, :[]

    attr_writer :logger

    def logger
      @logger ||= begin
        log = Logger.new($stdout)
        log.level = Logger::INFO
        log
      end
    end

    def encode_json data
      process_json :encode, data
    end

    def decode_json body
      process_json :decode, body
    end

    private

    def process_json meth, data
      MultiJson.send meth, data
    rescue
      raise Pusher::Error, "Could not #{meth} JSON: #{data.inspect}"
    end

    def default_client
      @default_client ||= Pusher::Client.new
    end
  end

  if ENV['PUSHER_URL']
    self.url = ENV['PUSHER_URL']
  end
end

require 'pusher/channel'
require 'pusher/query_encoder'
require 'pusher/request'
require 'pusher/resource'
require 'pusher/webhook'
