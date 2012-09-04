# encoding: UTF-8

module Astor
  class TrendMonitor
    attr_reader :error_count
  
    def initialize(collector)
      @collector = collector
  
      @error_count = {}
      @notified    = {}
    end
  
    def check(type, key)
      type    = type
      metric  = key
      id      = [type, key.gsub('.','-')].join('-')

      @error_count[id] ||= 0
 
      # Timespan to measure 
      ts   = Time.now.utc
      fifteen_min_ago = ts - ts.sec - 60 * 15
      one_min_ago     = ts - ts.sec - 60
  
      values = @collector.find(id, fifteen_min_ago, one_min_ago).map {|m| m[1] }

      return if values.size < 3

      current = values.pop
      mean    = values.mean
      std_dev = values.standard_deviation
  
      zscore = (current - mean) / std_dev

      x, y = (1..values.length).to_a, values
      linefit = LineFit.new
      linefit.setData(x, y)
      intercept, slope = linefit.coefficients

      # FIXME This should be configurable. There's a lot of arbitrary values here.
      # A score of 2 or -2 standard deviations in the last minute value is considered
      # an error. 3 consecutive changes is a severe change in the trend.
      # https://en.wikipedia.org/wiki/Standard_score
      case
        when zscore > 2
          if values[0..9].sum != 0
            @error_count[id] += 1

            if @error_count[id] == 3
              notify(:rise, id, type, key) unless notified?(id)
            else
              notify(:spike, id, type, key) unless notified?(id)
            end
          end
        when zscore < -2
          @error_count[id] += 1
          notify(:drop, id, type, key) unless notified?(id)
        else
          @error_count[id] = 0
          @notified[id] = false
      end

      @collector.logger.debug "TrendMonitor error count: #{@error_count.inspect}"
      @error_count
    end
 
    # TODO Store alerts.
    def notify(reason, id, type, key)
      msg = {
        timestamp:  Time.now.utc.iso8601, 
        reason:     reason,
        id:         id,
        type:       type, 
        key:        key
      }

      @collector.publish :alert, msg
      @notified[id] = true
    end
  
    def notified?(id)
      !!@notified[id]
    end
  end
end
