require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter 'vendor/bundle'
  add_filter 'spec'
end

require 'iij/sakagura'
require 'rspec'
require 'webmock/rspec'

WebMock.disable_net_connect!

module RequestMiddlewareExampleGroup
  def self.included(base)
    base.let(:endpoint) { "http://api.example.jp/1/" }
    base.let(:connection) { Faraday.new :url => endpoint }
    base.let(:middleware) { described_class.new(lambda{|env| env }, *middleware_options) }
  end

  def process(method = :get, &block)
    middleware.call(make_env(method, &block))
  end

  def make_env(method = :get, &block)
    connection.build_request(method, &block).to_env(connection)
  end
end

RSpec.configure do |config|
  config.include RequestMiddlewareExampleGroup, :type => :request_middleware
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
  ENV.fetch('IIJ_SAKAGURA_TEST_ACCESS_KEY')
end

def test_secret_key
  ENV.fetch('IIJ_SAKAGURA_TEST_SECRET_KEY')
end

def test_gp_service_code
  ENV.fetch('IIJ_SAKAGURA_TEST_GP_SERVICE_CODE')
end

def test_gp_endpoint
  ENV.fetch('IIJ_SAKAGURA_TEST_GP_ENDPOINT')
end

def signed_gp_client
  IIJ::Sakagura::GP::Client.new(:endpoint => test_gp_endpoint,
                                :access_key => test_access_key,
                                :secret_key => test_secret_key)
end
