#!/usr/bin/env ruby
# encoding: UTF-8

if ARGV.empty?
  puts 'Usage: ./client.rb <namespace> <metric> <value>'
  exit(2)
end

require 'bundler'
Bundler.require :client
require 'time'

statsd = Statsd.new '127.0.0.1', 8888
statsd.namespace = ARGV[0]

loop do 
  sleep 0.3

  k = ARGV[1]
  v = ARGV[2].to_i + rand(5)
  p [:sending, k, v, Time.now.utc.iso8601]

  statsd.count k, v
end
