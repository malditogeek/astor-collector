#!/usr/bin/env ruby
# encoding: UTF-8

##
## Consuming data from the event stream (zmq subscriber):
## MaxValueTracker will track and display the metric with the highest value.
##

require 'bundler'
Bundler.require :server
require 'time'

class MaxValueTracker
  def initialize
    @max = 0
  end

  def on_readable(socket, messages)
    messages.each {|msg| process *msg.copy_out_string.split(' ')  }
  end

  def process(channel, metric_in_json)
    metric = JSON.parse(metric_in_json)

    if metric['value'] > @max
      @max = metric['value']
      p [:NEW_MAXIMUM, metric]
    end
  end
end

ctx = EM::ZeroMQ::Context.new(1)
EM::run do
  socket = ctx.socket ZMQ::SUB, MaxValueTracker.new
  socket.identity = "tracker-#{Process.pid}"
  socket.connect "tcp://127.0.0.1:8890"
  socket.subscribe 'metric'
end
