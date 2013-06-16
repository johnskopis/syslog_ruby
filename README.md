# SyslogRuby

This gem implements the syslog protocol in pure ruby. The Syslog module that
uses the openlog(3) syscall can only have a single facility open. SyslogRuby
allows you to have as many loggers as you want.

## Installation

Add this line to your application's Gemfile:

    gem 'syslog_ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install syslog_ruby

## Usage

The syslog_ruby gem also implements a pure ruby version of the Syslog module:

    require 'syslog_compat'

To use the pure ruby version

    tcp = SyslogRuby::Logger.new('ruby', :LOCAL3, uri: 'tcp://127.0.0.1:514')
    udp = SyslogRuby::Logger.new('ruby', :LOCAL4, uri: 'udp://127.0.0.1:514')
    local = SyslogRuby::Logger.new('ruby', :LOCAL5, uri: '/dev/log')
    local.info "a message"

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
