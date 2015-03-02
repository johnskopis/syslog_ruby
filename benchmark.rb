#!/usr/bin/env ruby
#
$:.unshift File.dirname("lib/syslog_ruby")

require 'benchmark'
require 'syslog_ruby'


Benchmark.bm(20) do |x|
  x.report('single syslog') do
    Syslog.open
    225.times do
      Syslog.info "(single syslog) Logged via Syslog"
    end
    Syslog.close if Syslog.opened?
  end

  sleep 1

  x.report('single syslogger') do
    l1 = Logger::Syslog.new('test', Syslog::LOG_SYSLOG)
    225.times do
      l1.info "(single syslogger) Logged via Logger::Syslog (1)"
    end
  end

  sleep 1

  x.report('single pure ruby') do
    rl1 = SyslogRuby::Logger.new('pure-test1', :SYSLOG, uri: '/dev/log')
    225.times do
      rl1.info "(single pure ruby) logged via SyslogRuby::Logger (1)"
    end
  end

  sleep 1

  x.report('2 sysloggers') do
    l1 = Logger::Syslog.new('test2-1', Syslog::LOG_SYSLOG)
    l2 = Logger::Syslog.new('test2-2', Syslog::LOG_SYSLOG)
    225.times do
      l1.info "(2 sysloggers) logged via Logger::Syslog (1)"
      l2.info "(2 sysloggers) logged via Logger::Syslog (2)"
    end
  end

  sleep 1

  x.report('2 pure ruby') do
    rl1 = SyslogRuby::Logger.new('pure-test2-1', :SYSLOG, uri: '/dev/log')
    rl2 = SyslogRuby::Logger.new('pure-test2-2', :SYSLOG, uri: '/dev/log')
    225.times do
      rl1.info "(2 pure ruby) logged via SyslogRuby::Logger (1)"
      rl2.info "(2 pure ruby) logged via SyslogRuby::Logger (2)"
    end
  end
end
