module Astor
  class Metric

    attr_reader :id, :key, :type, :datapoints

    def initialize(datapoint)
      @id         = datapoint.id
      @key        = datapoint.key
      @type       = datapoint.type
      @datapoints = {}
    end

    # Add a new datapoint.
    def <<(datapoint)
      timeslot = @datapoints[datapoint.timestamp] ||= []
      timeslot << datapoint
    end

    # All the datapoint values for the given timestamps. If :purge option is true 
    # the datapoints at those timestamps will be removed (and persisted).
    def values_at(timestamps, opts={purge: false})
      datapoints = timestamps.inject([]) do |accum, ts| 
        accum += (opts[:purge] ? @datapoints.delete(ts) : @datapoints[ts]) if @datapoints.has_key?(ts)
        accum
      end
      datapoints.map(&:value)
    end

    # Timestamps to be broadcasted.
    def to_be_broadcasted(timestamps)
      values = values_at(timestamps)
      values.any? ? aggregate(values) : {}
    end

    # Timestamps to be persisted.
    def to_be_persisted(timestamps)
      values = values_at(timestamps, {purge: true})
      values.any? ? aggregate(values) : {}
    end

    # Should return a list of keys to be monitored. Can be an empty list.
    def to_be_monitored
      [@key]
    end

    # To be implemented on each subclass.
    def aggregate(*args)
      raise Exception.new("Missing *aggregate* implementation for #{self.class.name}")
    end

  end
end
