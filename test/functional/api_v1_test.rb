require_relative '../test_helper'

class APIv1Test < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    zmq        = MockEverything.new
    logger     = MockEverything.new
    @collector = Astor::Collector.new('/tmp/astor-testdb', @zmq, logger)

    now = Time.now.utc
    @one_minute_ago = now - now.sec - 60

    # Generate some fake data
    Time.stub :now, Time.at(@one_minute_ago) do
      @collector.save 'c', 'notifications', '50'
      @collector.save 'c', 'notifications', '50'
      @collector.save 'c', 'notifications', '50'
    end
    @collector.persist_metrics

    # Emulate Goliath server options
    @env = {'options' => {collector: @collector}}
  end

  def app
    Astor::APIv1
  end

  def test_metrics
    get "/v1/metrics", {}, @env
    assert_equal 200, last_response.status

    res = JSON.parse(last_response.body)

    assert_equal 1, res.length
    assert_equal 'c-notifications', res[0]['id']
  end

  def test_find
    get '/v1/metrics/c-notifications', {'offset' => '-5minutes'}, @env
    assert_equal 200, last_response.status

    res = JSON.parse(last_response.body)
    assert_equal 'c-notifications', res['id']
    assert_equal 'c', res['type']
    assert_equal 'notifications', res['key']
    assert_equal [[@one_minute_ago.iso8601, 150.0]], res['data']
  end

  def test_save
    post '/v1/metrics/c-notifications', {'value' => '20'}, @env
    assert_equal 201, last_response.status

    res = JSON.parse(last_response.body)

    assert @collector.metrics_index['c-notifications'].is_a? Astor::Counter

    assert_equal 20.0, res['value']
  end

  def test_delete
    delete '/v1/metrics/c-notifications', {}, @env
    assert_equal 200, last_response.status

    assert @collector.metrics_db.keys.empty?

    res = JSON.parse(last_response.body)
    assert_equal ["c-notifications|#{@one_minute_ago.iso8601}"], res
  end

  def teardown
    @collector.metrics_db.keys.map {|k| @collector.metrics_db.delete(k) }
  end
end
