module Astor
  class Datapoint

    attr_reader :type, :key, :value, :id, :timestamp

    def initialize(type, key, value)
      @type       = type
      @key        = key
      @value      = value.to_f
      @id         = "#{type}-#{key.gsub('.','-')}"
      @timestamp  = Time.now.utc.iso8601
    end

    def to_json
      dp = {
        id:         @id, 
        type:       @type, 
        key:        @key, 
        value:      @value, 
        timestamp:  @timestamp
      }
      dp.to_json
    end

  end
end
