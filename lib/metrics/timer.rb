module Astor
  class Timer < Metric

    def to_be_monitored
      [:max, :min, :mean].map {|agg| "#{@key}.#{agg}" }
    end

    def aggregate(values)
      [:max, :min, :mean].inject({}) do |accum,agg|
        accum["#{@key}.#{agg}"] = values.send(agg)
        accum
      end 
    end

  end
end
