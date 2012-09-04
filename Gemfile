source :rubygems

group :server do 
  gem 'leveldb-ruby', '0.14', require: 'leveldb'
  gem 'yajl-ruby',    '1.1.0', require: ['yajl', 'yajl/json_gem']
  gem 'foreman',      '0.40.0'

  # Trend monitor
  gem 'linefit',      '0.3.0'

  # PubSub socket
  gem 'em-zeromq',    '0.3.0'

  # REST API
  gem 'goliath',      '1.0.0', require: false
  gem 'grape',        '0.2.1', require: false
end

group :client do
  gem 'statsd-ruby',  require: 'statsd'
end

group :development do
  gem 'capistrano'
  gem 'capify-ec2'
end

group :test do
  gem 'rack-test', require: 'rack/test'
end
