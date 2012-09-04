# encoding: UTF-8

require 'rake'
require 'rake/testtask'

namespace :test do
  desc 'Unit tests'
  Rake::TestTask.new('unit') do |t|
    t.pattern = 'test/unit/*_test.rb'
  end

  desc 'Functional tests'
  Rake::TestTask.new('functional') do |t|
    t.pattern = 'test/functional/*_test.rb'
  end
end

Rake::Task[:test].prerequisites << 'test:unit'
Rake::Task[:test].prerequisites << 'test:functional'

task :default => :test
