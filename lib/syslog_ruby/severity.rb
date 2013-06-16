require 'syslog_ruby/lookup_from_const'

module SyslogRuby
  module Severity
    extend LookupFromConst
    EMERG = PANIC = 0
    ALERT = 1
    CRIT = 2
    ERR = ERROR = 3
    WARN = WARNING = 4
    NOTICE = 5
    INFO = 6
    DEBUG = 7
    NONE = 10
  end
end
