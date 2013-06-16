require 'syslog_ruby/lookup_from_const'

module SyslogRuby
  module Facility
    extend LookupFromConst
    KERN     =  0 << 3
    USER     =  1 << 3
    MAIL     =  2 << 3
    DAEMON   =  3 << 3
    AUTH     =  4 << 3
    SYSLOG   =  5 << 3
    LPR      =  6 << 3
    NEWS     =  7 << 3
    UUCP     =  8 << 3
    CRON     =  9 << 3
    AUTHPRIV = 10 << 3
    FTP      = 11 << 3
    NTP      = 12 << 3
    SECURITY = 13 << 3
    CONSOLE  = 14 << 3
    RAS      = 15 << 3
    LOCAL0   = 16 << 3
    LOCAL1   = 17 << 3
    LOCAL2   = 18 << 3
    LOCAL3   = 19 << 3
    LOCAL4   = 20 << 3
    LOCAL5   = 21 << 3
    LOCAL6   = 22 << 3
    LOCAL7   = 23 << 3
    NONE     = SYSLOG
  end
end
