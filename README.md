# Logstuff


Logstuff is a rubygem for writing application logs in a more structured form.

It will output the logs in JSON format to allow collection from logstash/beaver
or equivalent into a central logging store such as elasticsearch.

## Installation

Add this line to your application's Gemfile:

    gem 'logstuff'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install logstuff

## Usage

The example IRB session below shows examples of the usage of LogStuff and the associated JSON output generated.

   ```ruby
   # Setup LogStuff to output to STDOUT
   2.1.2 :001 > LogStuff.setup(:logger => LogStuff.new_logger(STDOUT, Logger::INFO))
    => true

   # Simple basic logging message
   2.1.2 :002 > LogStuff.info { "Test message" }
   {"@source":"logstuff","@tags":[],"@fields":{},"@severity":"info","message":"Test message","@timestamp":"2014-10-20T08:41:36.950904+00:00"}
    => true

   # Basic logging with additional tags for categorising messages
   2.1.2 :004 > LogStuff.info(:mail,:deliver) { "Test message" }
   {"@source":"logstuff","@tags":["mail","deliver"],"@fields":{},"@severity":"info","message":"Test message","@timestamp":"2014-10-20T08:42:07.589854+00:00"}
    => true

   # Basic logging with additional key/value pairs specified for inclusion in the @fields structure
   2.1.2 :008 > LogStuff.info(:key1 => '1234', :key2 => '5678') { "Test message" }
   {"@source":"logstuff","@tags":[],"@fields":{"key1":"1234","key2":"5678"},"@severity":"info","message":"Test message","@timestamp":"2014-10-20T08:43:04.035798+00:00"}
    => true

   # Using with tag method allows all log messages within the block to inherit those tags
   2.1.2 :009 > LogStuff.tag(:tag1) do
   2.1.2 :010 >     LogStuff.info { "A different log message" }
   2.1.2 :011?>   end
    {"@source":"logstuff","@tags":["tag1"],"@fields":{},"@severity":"info","message":"A different log message","@timestamp":"2014-10-20T08:44:06.329569+00:00"}
     => true

   # The same can be achieved with the metadata method
   2.1.2 :012 > LogStuff.metadata(:request_id => '345') do
   2.1.2 :013 >     LogStuff.info { "A different log message" }
   2.1.2 :014?>   end
   {"@source":"logstuff","@tags":[],"@fields":{"request_id":"345"},"@severity":"info","message":"A different log message","@timestamp":"2014-10-20T08:44:47.688320+00:00"}
    => true
   ```

## Configuring for use with Rails

To use with Rails first create a new logger and then pass that logger into LogStuff.setup. It is necessary
to use a wrapping function around to Logger.new to ensure that the autogenerated comment does not appear
at the top of the generated log file which is non-json and will confuse logstash/beaver.

   ```ruby
   # Custom Logging
   jsonlogger = LogStuff.new_logger("#{Rails.root}/log/output.json", Logger::INFO)
   LogStuff.setup(:logger => jsonlogger)
   ```


Often you might wish to use this library in conjunction with the logstasher gem for encapsulating request
logs and exceptions. The following block can be used to enable both gems and allow them to reuse a common
logger.

   ```ruby
   # Custom Logging
   jsonlogger = LogStuff.new_logger("#{Rails.root}/log/output.json", Logger::INFO)

   config.log_level = :info
   config.logstasher.enabled = true
   config.logstasher.suppress_app_log = false
   config.logstasher.logger = jsonlogger
   # Need to specifically set the logstasher loglevel since it will overwrite the one set earlier
   config.logstasher.log_level = Logger::INFO
   config.logstasher.source = 'logstasher'

   # Reuse logstasher logger with logstuff
   LogStuff.setup(:logger => jsonlogger)
   ```


## Contributing

1. Fork it ( http://github.com/withnale/logstuff/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
