require_relative '../test_helper'

class TimerTest < Test::Unit::TestCase
  def setup
    @datapoint = Astor::Datapoint.new 'ms', 'external_api.elapsed_time', '300'
    @metric    = Astor::Timer.new @datapoint
  end

  def test_datapoint_aggregation
    aggregated_pairs = @metric.aggregate [300.0, 200.0, 500.0, 100.0]
    expectation = {}
    expectation["#{@metric.key}.max"]  = 500.0
    expectation["#{@metric.key}.min"]  = 100.0
    expectation["#{@metric.key}.mean"] = 275.0

    assert_equal expectation, aggregated_pairs
  end
end

