require 'logger'

require_relative 'core_ext/enumerable'
require_relative 'em/protocols/statsd_server'
require_relative 'trend_monitor'
require_relative 'collector'
require_relative 'api/rest'

module Astor
  class Runner
    def initialize(opts)
      @opts = opts
    end

    def run!
      zmq_ctx = EM::ZeroMQ::Context.new(1)

      EM::run do
        zmq_pub = zmq_ctx.socket(ZMQ::PUB)
        zmq_pub.bind("tcp://#{@opts[:zmq]}")

        @collector = Astor::Collector.new(@opts[:db], zmq_pub, logger)

        logger.info "Starting metrics collector at udp://#{@opts[:srv]}"
        host, port = @opts[:srv].split(':')
        EM.open_datagram_socket host, port, EM::P::StatsdServer, @collector
     
        # Every second. Publish the active metrics over ZeroMQ.
        EM.add_periodic_timer(1) do
          @collector.broadcast_metrics
        end

        # Every minute. Aggregate/persist metrics and run TrendMonitor.
        EM.add_periodic_timer(60) do
          @collector.persist_metrics
          @collector.monitorize_trends
        end

        logger.info "Starting REST API at http://#{@opts[:rest]}"
        start_rest_api(@collector)

        # TODO persist saves last minute data, do something to save the current data state
        trap('TERM') { logger.info('SIGTERM received'); @collector.persist_metrics; EM.stop }
        trap('INT')  { logger.info('SIGINT received');  @collector.persist_metrics; EM.stop }

        logger.info "Ready, publishing events (ZeroMQ) at tcp://#{@opts[:zmq]}"
      end
    end

    # Start REST API
    def start_rest_api(collector)
      Goliath.env     = :production
      host, port      = @opts[:rest].split(':')

      server          = Goliath::Server.new(host, port)
      server.logger   = logger
      server.api      = REST::API.new
      server.app      = Goliath::Rack::Builder.build(REST::API, server.api)
      server.plugins  = []
      server.options  = {collector: collector}

      server.start
    end

    def logger
      return @logger if @logger

      @logger = Logger.new($stdout)
      @logger.level = @opts[:vrb] ? Logger::DEBUG : Logger::INFO
      @logger
    end
  end
end

