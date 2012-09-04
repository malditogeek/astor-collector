# encoding: UTF-8

require 'time'

require_relative 'metrics/datapoint'
require_relative 'metrics/metric'
require_relative 'metrics/counter'
require_relative 'metrics/gauge'
require_relative 'metrics/timer'

module Astor
  class Collector
  
    attr_reader :metrics_db, :logger, :metrics_index

    # Lookup table for the supported metric types
    TYPE_LOOKUP = {
      'c'  => Counter,
      'g'  => Gauge,
      'ms' => Timer
    }

    # TODO collect stats 
    def initialize(db_path, zmq, logger)
      @metrics_db     = LevelDB::DB.new db_path
      @zmq            = zmq
      @logger         = logger
      @metrics_index  = {}
    end

    def keys
      keys = Set.new

      @metrics_db.keys.inject(keys) do |accum, key| 
        metric_id    = key.split('|')[0]
        metric_type  = metric_id.split('-')[0]
        metric_key   = metric_id.split('-')[1..-1].join('.')

        accum << {type: metric_type, key: metric_key, id: metric_id}
        accum
      end

      # FIXME show non persisted keys?
      #@metrics_index.values.inject(keys) do |accum, metric|
      #  accum << {type: metric.type, key: metric.key, id: metric.id}
      #  accum
      #end

      keys.to_a
    end

    def save(type, key, value)
      logger.debug "Save: #{type}, #{key}, #{value}"

      datapoint = Datapoint.new(type, key, value)

      if TYPE_LOOKUP[type]
        @metrics_index[datapoint.id] ||= TYPE_LOOKUP[type].new(datapoint)
        @metrics_index[datapoint.id] <<  datapoint
      else
        logger.warn "Invalid datapoint received: #{datapoint.inspect}"
      end

      datapoint
    end
  
    def find(id, from, to)
      logger.debug "Find: #{id}, #{from} => #{to}"

      return [] if from > to

      from_key  = [id, from.iso8601].join('|')
      to_key    = [id, to.iso8601].join('|')
      values = @metrics_db.each(:from => from_key, :to => to_key).map do |key, value|
        timestamp = key.split('|')[1]
        [timestamp, value.to_f]
      end
 
      values
    end

    def delete(id)
      @metrics_index.delete(id)
      @metrics_db.keys.each do |key|
        @metrics_db.delete(key) if key.split('|')[0] == id
      end
    end

    def broadcast_metrics
      logger.debug 'Broadcasting metrics'

      one_second_ago = (Time.now - 1).utc.iso8601

      @metrics_index.each do |id,metric|
        metric.to_be_broadcasted([one_second_ago]).each do |key, value|

          msg = {
            type:       metric.type, 
            key:        key, 
            value:      value, 
            timestamp:  one_second_ago
          }

          publish :metric, msg
        end
      end
    end
  
    def publish(event, content) 
      msg = {event: event}.merge(content)
      @zmq.send_msg [event, msg.to_json].join(' ')
    end
  
    def persist_metrics
      logger.debug 'Persisting metrics'

      now = Time.now.utc
      one_minute_ago = (now - now.sec - 60)

      last_60_secs = (0..59).map {|sec| (one_minute_ago + sec).iso8601 }
      timestamp = one_minute_ago.iso8601

      @metrics_index.each do |id,metric|
        m = metric.to_be_persisted(last_60_secs)
        m.each do |key, value|
          id = [metric.type, key.gsub('.','-')].join('-')
          db_key = [id, one_minute_ago.iso8601].join('|')

          @metrics_db.put db_key, value.to_s
        end
      end
    end
  
    def monitorize_trends
      logger.debug 'Monitoring'

      @monitor ||= Astor::TrendMonitor.new(self)
      @metrics_index.each do |id, metric|
        metric.to_be_monitored.each {|key| @monitor.check(metric.type, key) }
      end
    end

  end
end
