require "logstuff/version"


require 'thread'

module LogStuff
  extend self

  attr_accessor :logger_path
  attr_accessor :logger, :source

  NAMESPACE = :log


  def get_thread_current(name)
    Thread.current[NAMESPACE] ||= {
        :current_fields => {},
        :current_tags   => Set.new
    }
    Thread.current[NAMESPACE][name].dup
  end


  def set_thread_current(name, value)
    Thread.current[NAMESPACE]       ||= {
        :current_fields => {},
        :current_tags   => Set.new
    }
    Thread.current[NAMESPACE][name] = value.dup
  end


  def self.log(severity = 'info', *args, &block)

    return unless block_given?

    # Ignore if we are not logging this severity
    return unless logger.send("#{severity}?")

    local_fields = {}
    local_tags   = Set.new
    args.each do |arg|
      case arg
        when Hash
          local_fields.merge!(arg)
        when Symbol
          local_tags.add(arg)
        when Array
          local_tags.merge(arg)
      end
    end

    msg = yield

    event = LogStash::Event.new('@source' => source,
                                '@severity' => severity,
                                'message' => msg,
                                '@tags' => get_thread_current(:current_tags).merge(local_tags).to_a,
                                '@fields' => get_thread_current(:current_fields).merge(local_fields)
    )
    logger << event.to_json + "\n"
  end


  %w( fatal error warn info debug ).each do |severity|
    eval <<-EOM, nil, __FILE__, __LINE__ + 1
      def self.#{severity}(*args, &block)
        self.log(:#{severity}, *args, &block )
      end
    EOM
  end


  def tag(*tags, &block)
    original_tags = get_thread_current(:current_tags)
    current_tags  = original_tags.dup + tags.flatten
    set_thread_current(:current_tags, current_tags)
    yield
    set_thread_current(:current_tags, original_tags)
  end


  def metadata(*pairs, &block)
    original_fields = get_thread_current(:current_fields) || {}
    current_fields  = original_fields.dup
    pairs.flatten.each do |pair|
      pair.each do |k, v|
        current_fields[k.to_sym] = v
      end
    end
    set_thread_current(:current_fields, current_fields)
    yield
    set_thread_current(:current_fields, original_fields)
  end


  def setup(params)
    require 'logstash-event'
    self.logger_path = params[:path] || "logstuff.json"
    self.logger = params[:logger] || new_logger(self.logger_path, params[:loglevel])
    self.source = params[:source] || 'logstuff'
  end


  def new_logger(path, loglevel)
    if path.class == String
      FileUtils.touch path # prevent autocreate messages in log
    end
    newlogger = Logger.new path
    newlogger.level = loglevel unless loglevel.nil?
    newlogger
  end


end
