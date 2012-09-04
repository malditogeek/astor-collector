require_relative '../test_helper'

class CollectorTest < Test::Unit::TestCase
  def setup
    @zmq        = MiniTest::Mock.new
    logger      = MockEverything.new
    @collector  = Astor::Collector.new('/tmp/astor-testdb', @zmq, logger)

    now = Time.now.utc
    @one_minute_ago = now - now.sec - 60
  end

  def test_save
    @collector.save 'c' , 'notifications', '50'
    @collector.save 'ms', 'external_api.elapsed_time', '300'
    @collector.save 'g' , 'users.online', '5' 

    # Verify metric type lookup
    assert @collector.metrics_index['c-notifications'].is_a? Astor::Counter
    assert @collector.metrics_index['ms-external_api-elapsed_time'].is_a? Astor::Timer
    assert @collector.metrics_index['g-users-online'].is_a? Astor::Gauge

    # Verify datapoints are being added to the metric
    assert_equal 1, @collector.metrics_index['c-notifications'].datapoints.length
    assert_equal 1, @collector.metrics_index['ms-external_api-elapsed_time'].datapoints.length
    assert_equal 1, @collector.metrics_index['g-users-online'].datapoints.length
  end

  def test_save_invalid_datapoint
    @collector.save '_invalid_type_' , 'notifications', '50'

    assert @collector.metrics_index.empty?
  end

  def test_keys
    Time.stub :now, Time.at(@one_minute_ago) do
      @collector.save 'c', 'notifications', '50'
    end
    @collector.persist_metrics

    assert_equal [{type: 'c', key: 'notifications', id: 'c-notifications'}], @collector.keys
  end

  def test_find
    Time.stub :now, Time.at(@one_minute_ago) do
      @collector.save 'c', 'notifications', '50'
      @collector.save 'c', 'notifications', '50'
      @collector.save 'c', 'notifications', '50'
    end
    @collector.persist_metrics

    values = @collector.find('c-notifications', @one_minute_ago, Time.now)
    assert_equal [[@one_minute_ago.iso8601, 150.0]], values
  end
  
  def test_delete
    Time.stub :now, Time.at(@one_minute_ago) do
      @collector.save 'c', 'notifications', '50'
      @collector.save 'c', 'notifications', '50'
      @collector.save 'c', 'notifications', '50'
    end
    @collector.persist_metrics
    @collector.delete('c-notifications')

    assert_equal [], @collector.metrics_db.keys
  end

  def test_broadcast_metrics
    one_second_ago = Time.now.utc - 1

    event   = :metric
    content = {
      type:       'c',
      key:        'notifications', 
      value:      50.0, 
      timestamp:  one_second_ago.iso8601
    }

    msg = {event: event}.merge(content)
    arg = [event, msg.to_json].join(' ')
    @zmq.expect(:send_msg, nil, [arg])

    Time.stub :now, Time.at(one_second_ago) do
      @collector.save 'c', 'notifications', '50'
    end
    @collector.broadcast_metrics

    assert @zmq.verify
  end

  def test_persist_metrics
    Time.stub :now, Time.at(@one_minute_ago) do
      @collector.save 'c', 'notifications', '50'
    end
    @collector.persist_metrics

    key = "c-notifications|#{@one_minute_ago.iso8601}"
    assert_equal '50.0', @collector.metrics_db[key]
  end

  def teardown
    @collector.metrics_db.keys.map {|k| @collector.metrics_db.delete(k) }
  end

end

