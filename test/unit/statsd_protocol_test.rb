require_relative '../test_helper'

class StatsdProtocolTest < Test::Unit::TestCase
 
  def setup
    @host = '127.0.0.1'
    @port = 9999

    @client = Statsd.new @host, @port
    @client.namespace = 'awesomeapp'
  end

  def run_statsd_server_with(store, &block)
    EM.run {

      EM.open_datagram_socket @host, @port, EM::Protocols::StatsdServer, store

      block.call

      EM::add_timer(0.01) {
        store.verify
        EM.stop
      }
    }
  end

  def test_gauge_command
    store = MiniTest::Mock.new
    store.expect(:save, true, ['g', 'awesomeapp.current_users', '50']) 

    run_statsd_server_with store do
      @client.gauge 'current_users', 50
    end
  end

  def test_count_command
    store = MiniTest::Mock.new
    store.expect(:save, true, ['c', 'awesomeapp.notifications', '30']) 

    run_statsd_server_with store do
      @client.count 'notifications', 30
    end
  end

  def test_increment_command
    store = MiniTest::Mock.new
    store.expect(:save, true, ['c', 'awesomeapp.api_calls', '1']) 

    run_statsd_server_with store do
      @client.increment 'api_calls'
    end
  end

  def test_decrement_command
    store = MiniTest::Mock.new
    store.expect(:save, true, ['c', 'awesomeapp.api_calls', '-1']) 

    run_statsd_server_with store do
      @client.decrement 'api_calls'
    end
  end

  def test_timing_command
    store = MiniTest::Mock.new
    store.expect(:save, true, ['ms', 'awesomeapp.request', '250']) 

    run_statsd_server_with store do
      @client.timing 'request', 250
    end
  end

end
