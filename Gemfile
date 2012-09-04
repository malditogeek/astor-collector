source :rubygems

repos = {
  fwd:      'git@github.com:forward/fwd.git',
  statsd:   'git://github.com/github/statsd-ruby.git',
  goliath:  'git://github.com/postrank-labs/goliath.git'
}

group :server do 
  gem 'leveldb-ruby', '0.14', require: 'leveldb'
  gem 'eventmachine', '1.0.0.beta.4'
  gem 'yajl-ruby',    '1.1.0', require: ['yajl', 'yajl/json_gem']
  gem 'foreman',      '0.40.0'

  # Trend monitor
  gem 'linefit',      '0.3.0'

  # PubSub socket
  gem 'em-zeromq',    '0.3.0'

  # REST API
  gem 'goliath',      require: false, git: repos[:goliath]
  gem 'grape',        require: false
end

group :client do
  gem 'statsd-ruby',  git: repos[:statsd], require: 'statsd'
end

group :development do
  gem 'capistrano'
  gem 'capify-ec2'
end

group :test do
  gem 'rack-test', require: 'rack/test'
end
