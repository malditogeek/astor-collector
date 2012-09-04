module Astor
  class Gauge < Metric

    def aggregate(values)
      {@key => values.last}
    end

  end
end
