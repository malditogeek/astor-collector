require_relative '../test_helper'

class CounterTest < Test::Unit::TestCase
  def setup
    @datapoint = Astor::Datapoint.new 'c', 'cache.hits', '5'
    @metric    = Astor::Counter.new @datapoint
  end

  def test_datapoint_aggregation
    aggregated_pair = @metric.aggregate [5.0, 10.0, 20.0, 5.0]
    expectation = {}
    expectation[@metric.key] = 40.0

    assert_equal expectation, aggregated_pair
  end
end

