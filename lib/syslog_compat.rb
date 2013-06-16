require 'syslog_ruby'

module Syslog
  include SyslogRuby::Severity
  include SyslogRuby::Facility
  @@logger = nil

  class << self
    def setup_severity_methods
      SyslogRuby::Severity.constants.each do |level_name|
        level = SyslogRuby::Severity.const_get level_name

        self.class.send :define_method, level_name.downcase do |*args|
          @@logger.log level, *args
        end
        self.class.send :define_method, level_name.downcase.to_sym do |*args|
          @@logger.log level, *args
        end
      end
    end

    def open(ident = 'ruby', logopt = nil, facility = Syslog::LOG_LOCAL6)
      open_opt(ident, logopt, facility)
    end

    def open_opt(ident = 'ruby', logopt = nil, facility = Syslog::LOG_LOCAL6, options = {})
      options[:uri] = options[:uri] || find_syslog_socket
      @@logger ||= ::SyslogRuby::Logger.new(ident, facility, options)
      if block_given?
        yield @@logger
        @@logger.close
      else
        @@logger
      end
    end

    def find_syslog_socket
      %w[
        /dev/log
        /var/run/syslog
      ].find do |file|
        file if File.exists?(file)
      end
    end

    def info(*args)
      @@logger.info(*args)
    end

    def log(*args)
      @@logger.log(*args)
    end

    def inspect
      @@logger.inspect
    end

    def close
      raise RuntimeError.new "syslog not open" unless @@logger
      @@logger.close
    ensure
      @@logger = nil
    end

    def reopen(*args)
      self.close
      self.open(*args)
    end

    def opened?
      @@logger ? @@logger.opened? : false
    end

    def mask
      @@logger.mask if @@logger
    end

    def mask=(priority_mask)
      @@logger.mask = priority_mask if @@logger
    end

    def LOG_MASK(level)
      @@logger.LOG_MASK(level) if @@logger
    end

    def LOG_UPTO(level)
      @@logger.LOG_UPTO(level) if @@logger
    end

    def instance
      @@logger if @@logger
    end

    def ident
      @@logger.ident if @@logger
    end

    def options
      @@logger.options if @@logger
    end
  end

  self.setup_severity_methods
end
