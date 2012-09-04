require_relative '../test_helper'

class TrendMonitorTest < Test::Unit::TestCase
  attr_reader :type, :key, :metric_id
 
  def setup
    zmq         = MockEverything.new
    logger      = MockEverything.new
    @collector  = Astor::Collector.new('/tmp/testdb', zmq, logger)
    @monitor    = Astor::TrendMonitor.new(@collector)

    # Metric used for the tests:
    @type = 'c'
    @key  = 'notifications'
    @metric_id   = "#{@type}-#{@key.gsub('.','-')}"
  end

  # Helper
  def db_key(timestamp)
    [metric_id, timestamp].join('|')
  end

  # Helper
  def one_minute_ago
    t = Time.now.utc
    (t - t.sec- 60).iso8601
  end

  # Helper
  def generate_15min_data(type, key, values)
    now   = Time.now.utc
    from  = now - now.sec - (60 * 15)
    to    = now - now.sec - 60

    until from > to do
      @collector.metrics_db.put db_key(from.iso8601), values.shift.to_s
      from += 60
    end
  end

  def test_monitor_normal_traffic_pattern
    values = []
    15.times { values << (100 + rand(20)) }
    generate_15min_data(type, key, values)

    @monitor.check(type, key)

    assert_equal 0, @monitor.error_count[metric_id]
  end

  def test_monitor_increased_traffic_pattern
    values = []
    15.times { values << (100 + rand(20)) }
    generate_15min_data(type, key, values)

    @collector.metrics_db.put db_key(one_minute_ago), 200.to_s
    @monitor.check(type, key)

    assert_equal 1, @monitor.error_count[metric_id]
  end

  def test_monitor_decreased_traffic_pattern
    values = []
    15.times { values << (100 + rand(20)) }
    generate_15min_data(type, key, values)

    @collector.metrics_db.put db_key(one_minute_ago),  50.to_s
    @monitor.check(type, key)

    assert_equal 1, @monitor.error_count[metric_id]
  end

  def test_monitor_zero_traffic_pattern
    values = [0,0,0,0,0,0,0,0,0,0,0,0,40,60,70]
    generate_15min_data(type, key, values)

    @collector.metrics_db.put db_key(one_minute_ago), 50.to_s
    @monitor.check(type, key)

    assert_equal 0, @monitor.error_count[metric_id]
  end

  def teardown
    @collector.metrics_db.keys.map {|k| @collector.metrics_db.delete(k) }
  end

end
