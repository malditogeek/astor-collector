module Astor
  class Counter < Metric

    def aggregate(values)
      {@key => values.sum}
    end

  end
end
