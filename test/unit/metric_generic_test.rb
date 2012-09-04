require_relative '../test_helper'

class GenericMetricTest < Test::Unit::TestCase
  def setup
    @datapoint = Astor::Datapoint.new 'c', 'cache.hits', '5'
    @metric    = Astor::Metric.new @datapoint
  end

  def test_intial_values
    assert_equal @datapoint.id, @metric.id
    assert_equal @datapoint.type, @metric.type
    assert_equal @datapoint.key, @metric.key
  end

  def test_add_a_datapoint
    @metric << @datapoint
    assert_equal @metric.datapoints[@datapoint.timestamp][0], @datapoint
  end

  def test_retrieve_values
    @metric << @datapoint
    values = @metric.values_at [@datapoint.timestamp]
    assert_equal [5.0], values
  end

  def test_aggregate_exception
    assert_raise Exception do
      @metric.aggregate
    end
  end
end

