require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter 'vendor/bundle'
  add_filter 'spec'
end

require 'iijapi'
require 'rspec'
require 'webmock/rspec'

WebMock.disable_net_connect!

require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.configure_rspec_metadata!
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end
