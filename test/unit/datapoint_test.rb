require_relative '../test_helper'

class DatapointTest < Test::Unit::TestCase
  def setup
    @datapoint = Astor::Datapoint.new 'c', 'cache.hits', '5'
  end

  def test_type
    assert_equal 'c', @datapoint.type
  end

  def test_key
    assert_equal 'cache.hits', @datapoint.key
  end

  def test_value_is_coerced
    assert_equal 5.0, @datapoint.value
  end

  def test_id_format
    assert_equal 'c-cache-hits', @datapoint.id
  end

  def test_timestamp_format_is_utc_iso8601
    assert_match /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, @datapoint.timestamp
  end

  def test_invalid_datapoint
    datapoint = Astor::Datapoint.new 'c', 'foo', 'bar'
    assert_equal 0.0, datapoint.value
  end
end

