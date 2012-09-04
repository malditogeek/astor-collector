# encoding: UTF-8

require 'goliath/api'
require 'goliath/server'
require 'grape'

require_relative 'revisions/v1'

# Grape API description
module Astor
  class API < Grape::API
    mount Astor::APIv1
  end
end

# Request logger middleware
module Goliath
  module Rack
    class RequestLogger
      def initialize(app, *opts)
        @app  = app
        @opts = opts
      end

      def call(env)
        method  = env['REQUEST_METHOD']
        uri     = env['REQUEST_URI']
        version = env['HTTP_VERSION']

        env.logger.info "#{method} #{uri} HTTP/#{version}"

        @app.call(env)
      end
    end
  end
end

# Goliath adapter
module Astor
  module REST
    class API < Goliath::API
      use Goliath::Rack::RequestLogger

      def response(env)
        Astor::API.call(env)
      end
    end
  end
end
