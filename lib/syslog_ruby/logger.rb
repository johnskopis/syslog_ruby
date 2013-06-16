require 'socket'

module SyslogRuby
  class Logger
    attr_accessor :ident, :facility, :socket, :hostname, :mask, :log_uri
    class << self
      def setup_severity_methods
        SyslogRuby::Severity.constants.each do |level_name|
          level = SyslogRuby::Severity.const_get level_name

          define_method(level_name.downcase) do |*args|
            message = args.shift
            facility = args.shift || send(:facility)
            _log(facility, level, message)
          end
        end
      end
    end

    @@facilities = {}
    @@severities = {}
    Facility.setup_constants @@facilities
    Severity.setup_constants @@severities
    self.setup_severity_methods

    def initialize(ident = 'ruby',
                   facility = Facility::LOCAL6,
                   options = {})
      @ident = "#{ident}[#{$$}]"
      @facility = _configure_facility(facility)
      @mask = LOG_UPTO(Severity::DEBUG)
      @log_uri = options.fetch(:uri, 'testing')
      @hostname = Socket.gethostname.split('.').first
      _open
    end

    def _configure_facility(facility)
      case facility
      when Integer || Fixnum
        facility
      when Symbol || String
        Facility[Facility]
      else
        Facility::NONE
      end
    end

    def log(level, message, *message_args)
      level = case level
      when Integer || Fixnum
        level
      when Symbol || String
        Severity[level]
      else
        Severity::INFO
      end
      _log(facility, level, message, *message_args)
    end

    def close
      raise RuntimeError.new "syslog not open" if socket.closed?
      socket.close
    end

    def reopen(*args)
      close && _open
    end

    def LOG_MASK(level)
      Severity[level]
    end

    def LOG_UPTO(level)
      (0...Severity[level]).inject(Integer(0)) do |mask, i|
        mask|i
      end
    end

    def opened?
      socket && !socket.closed?
    end

    def options
      0
    end

  private

    def _connect_unix(path)
      @local = true
      begin
        @socket = UNIXSocket.new(path)
      rescue Errno::EPROTOTYPE => e
        raise unless e.message =~ /Protocol wrong type for socket/
        @socket = Socket.new Socket::PF_UNIX, Socket::SOCK_DGRAM
        @socket.connect Socket.pack_sockaddr_un(path)
      end
    end

    def _connect_udp(uri)
      host, port = uri[6..-1].split(':')
      @socket = UDPSocket.new
      @socket.connect(host, port.to_i)
    end

    def _connect_tcp(uri)
      host, port = uri[6..-1].split(':')
      @socket = TCPSocket.new(host, port.to_i)
    end

    def _connect_test
      @socket = STDERR.dup.fileno
    end

    def _open
      if @log_uri.start_with? '/'
        _connect_unix(@log_uri)
      elsif @log_uri.start_with? 'tcp://'
        _connect_tcp(@log_uri)
      elsif @log_uri.start_with? 'udp://'
        _connect_udp(@log_uri)
      elsif @log_uri == 'testing'
        _connect_test
      else
        raise RuntimeError.new 'unknown :uri ' \
          'must be one of path, tcp://, or udp://'
      end
    rescue => e
      STDERR.puts "An exception (#{e.message}) occured while connecting to: "\
        "#{@log_uri}."
    end

    def _log(facility, level, message, *message_args)
      return unless level & mask
      msg = if message_args.length > 0
              message % message_args
            else
              message
            end

      proto_msg = if @local
                    "<#{facility + level}> "\
                      "#{ident}" \
                      ": " \
                      "#{msg}\n"
                  else
                    "<#{facility + level}> "\
                      "#{Time.now.strftime('%b %d %H:%M:%S')} " \
                      "#{hostname} " \
                      "#{ident}" \
                      ": " \
                      "#{msg}\n"
                  end

      begin
        !!socket.write(proto_msg)
      rescue => e
        retries ||= 0
        retries += 1
        if retries < 10
          _open
          retry if opened?
        else
          STDERR.puts "syslog is down!! tried to log: #{proto_msg}"
        end
      end
    end
  end
end
