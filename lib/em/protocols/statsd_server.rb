module EventMachine
  module Protocols

    # StatsD protocol implementation.
    #
    class StatsdServer < EM::Connection

      def initialize(collector)
        @collector = collector
      end

      def receive_data(data)
        msg, type  = data.split('|')
        metric, value = msg.split(':')

        @collector.save type, metric, value
      end
    end

  end
end
