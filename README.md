Astor, an alternative to StatsD+Graphite
========================================

![Astor Piazzolla](http://i.imgur.com/TPuRo.jpg)

This is: astor-collector
---------------
Metric collector and REST API. Based on EventMachine, Goliath and LevelDB.

You'll also need: astor-dashboard
---------------
Real-time metric visualization. Based on SocketStream (Node) and Backbone. [Find it here.](https://github.com/malditogeek/astor-dashboard)

Collector features
------------------

  * API compatible with StatsD, push data with any StatsD client
  * Second-by-second data resolution for active metrics
  * Minute-by-minute data resolution for archived metrics
  * Unlimited retention (well, as much as you can store)
  * Metric trend monitoring and alerting
  * Event streaming through ZeroMQ pub/sub
  * REST API

Pre-requisites
--------------

  * Ruby 1.9+
  * ZeroMQ dev 

Getting started
---------------

If you already have a working Ruby environment, should be as easy as:

    bundle install
    ./astor

Deployment
----------

Deploying Astor to EC2 is pretty straight forward. On AWS Console:

  * Create a new Amazon EC2 instance using the _Ubuntu 12.04_ AMI.
  * We'll use capify-ec2 so you need to [tag your instance properly](http://i.imgur.com/owe8P.png)
  * Customize your Security Groups and [open the right ports](http://i.imgur.com/BnBei.png)
  * Once the instance is up and running, ssh into it and run:


        sudo mkdir /var/astor
        sudo chown -R ubuntu:ubuntu /var/astor
        sudo apt-get update
        sudo apt-get install git build-essential libxslt-dev libxml2-dev ruby1.9.3 libzmq-dev
        sudo gem install bundler


Then, on your local clone:

  * Copy _config/astor.yml.sample_ to _config/astor.yml_ and customize it if needed 
  * Copy _config/deploy.rb.sample_ to _config/deploy.rb_ and customize it with your repository
  * Copy _config/ec2.yml.sample_ to _config/ec2.yml_ and complete it with [your EC2 keys](http://i.imgur.com/UM9sa.png)


        cap deploy:setup
        cap deploy


About Heroku: Is not possible to route UDP traffic at the moment but this may change in the future (https://groups.google.com/forum/?fromgroups=#!topic/heroku/z6haBrCQ9ZA)

REST API
--------

_id_ format is: type-metric-key, for example: 

  * product.clicks counter => c-product-clicks)
  * api.request timer => ms-api-request
  * current.users gauge => g-current-users

Availabe methods:

  * GET http://127.0.0.1:8889/v1/metrics
    * List of metrics

  * GET http://127.0.0.1:8889/v1/metrics/:id
    * Get datapoints (minute resolution) for the given metric id
    * Optional parameteres:
      * offset: -1day, -7days, -1month

  * POST http://127.0.0.1:8889/v1/metrics/:id
    * Post a datapoint for the given metric id
    * Mandatory parameters:
      * value: metric value

  * DELETE http://127.0.0.1:8889/v1/metrics/:id 
    * Delete all datapoints for the given metric id

Event Stream
------------

[Check example](https://github.com/malditogeek/astor-collector/blob/master/examples/stream_consumer.rb)
  
TODO
----

  * Alerts:
    - Configurable thresholds (per metric maybe?)
    - Storage
    - Expose as REST resource (POST deploy notifications, etc)
  * Configurable data retention
