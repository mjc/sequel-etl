require 'sequel'

module Sequel
  class ETL
    attr_accessor :connections
    attr_accessor :logger

    ORDERED_ETL_OPERATIONS = [
      :ensure_destination,
      :before_etl,
      :etl,
      :after_etl
    ]

    ITERATOR_OPERATIONS = [
      :start,
      :step,
      :stop
    ]

    def self.defaults
      { connections: @connections }
    end

    def initialize attributes = {}
      self.class.defaults.merge(attributes).each do |key, value|
        self.send "#{key}=", value
      end
      default_logger! unless attributes.keys.include?(:logger)
    end

    def config &block
      yield self if block_given?
      self
    end

    # A little metaprogramming to consolidate the generation of our sql
    # generating / querying methods. Note that we don't metaprogram the etl
    # operation as it's a little more complex.
    #
    # This will produce methods of the form:
    #
    #   def [name] *args, &block
    #     if block_given?
    #       @[name] = block
    #     else
    #       @[name].call self, *args if @[name]
    #     end
    #   end
    #
    # for any given variable included in the method name's array
    (ORDERED_ETL_OPERATIONS - [:etl]).each do |method|
      define_method method do |*args, &block|
        if block
          instance_variable_set("@#{method}", block)
        else
          instance_variable_get("@#{method}").
            call(self, *args) if instance_variable_get("@#{method}")
        end
      end
    end

    def etl *args, &block
      if block_given?
        @etl = block
      else
        if iterate?
          if @etl
            current = start
            @etl.call self, current, current += step while stop >= current
          end
        else
          @etl.call self, *args if @etl
        end
      end
    end

    # A little more metaprogramming to consolidate the generation of
    # our sql generating / querying methods.
    #
    # This will produce methods of the form:
    #
    #   def [method] *args, &block
    #     if block
    #       @_[method]_block = block
    #     else
    #       # cache block's result
    #       if defined? @[method]
    #         @[method]
    #       else
    #         @[method] = @_[method]_block.call(self, *args)
    #       end
    #     end
    #   end
    #
    # for any given variable included in the method name's array
    ITERATOR_OPERATIONS.each do |method|
      define_method method do |*args, &block|
        warn_args_will_be_deprecated_for method unless args.empty?

        if block
          instance_variable_set("@_#{method}_block", block)
        else
          if instance_variable_defined?("@#{method}")
            instance_variable_get("@#{method}")
          else
            instance_variable_set("@#{method}",
                                  instance_variable_get("@_#{method}_block")
                                  .call(self, *args))
          end
        end
      end
    end

    def perform options = {}
      (ORDERED_ETL_OPERATIONS - [*options[:except]]).each do |method|
        send method
      end
    end

    def run(source,sql)
      time_and_log(sql: sql) do
        connections[source].run sql
      end
    end

    def fetch(source,sql)
      time_and_log(sql: sql) do
        connections[source].fetch sql
      end
    end

    def info data = {}
      logger.info data.merge(emitter: self) if logger?
    end

    def debug data = {}
      logger.debug data.merge(emitter: self) if logger?
    end

    private
    def iterate?
      ITERATOR_OPERATIONS.all? do |method|
        instance_variable_defined?("@_#{method}_block")
      end
    end

    def default_logger!
      @logger = default_logger
    end

    def logger?
      !!@logger
    end

    def default_logger
      ::Logger.new(STDOUT).tap do |logger|
        logger.formatter = proc do |severity, datetime, progname, msg|
          event_details =  "[#{datetime}] #{severity} #{msg[:event_type]}"

          emitter_details =  "\"#{msg[:emitter].description || 'no description given'}\""
          emitter_details += " (object #{msg[:emitter].object_id})"

          leadin = "#{event_details} for #{emitter_details}"

          case msg[:event_type]
          when :query_start
            "#{leadin}\n#{msg[:sql]}\n"
          when :query_complete
            "#{leadin} runtime: #{msg[:runtime]}s\n"
          else
            "#{leadin}: #{msg[:message]}\n"
          end
        end
      end
    end

    def time_and_log data = {}, &block
      start_runtime = Time.now
      debug data.merge(event_type: :query_start)
      retval = yield
      info data.merge(event_type: :query_complete,
                      runtime: Time.now - start_runtime)
      retval
    end
  end
end
