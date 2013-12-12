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

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.configure_rspec_metadata!
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true

  c.filter_sensitive_data("<ACCESS_KEY>") do
    test_access_key
  end
  c.filter_sensitive_data("<SECRET_KEY>") do
    test_secret_key
  end
  c.filter_sensitive_data("<GP_SERVICE_CODE>") do
    test_gp_service_code
  end
  c.filter_sensitive_data("<GP_ENDPOINT>") do
    test_gp_endpoint
  end
end

def test_access_key
  ENV.fetch('IIJAPI_TEST_ACCESS_KEY')
end

def test_secret_key
  ENV.fetch('IIJAPI_TEST_SECRET_KEY')
end

def test_gp_service_code
  ENV.fetch('IIJAPI_TEST_GP_SERVICE_CODE')
end

def test_gp_endpoint
  ENV.fetch('IIJAPI_TEST_GP_ENDPOINT')
end

def signed_gp_client
  IIJAPI::GP::Client.new(:endpoint => test_gp_endpoint,
                         :access_key => test_access_key,
                         :secret_key => test_secret_key)
end
