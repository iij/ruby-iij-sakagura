require 'helper'

shared_examples_for "valid signature" do
  let(:valid_signature) do
    digest = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, secret_key, string_to_sign)
    Base64.encode64(digest).chomp
  end

  it do
    response = lambda do |request|
      if CGI.parse(request.body)['Signature'][0] == valid_signature
        { :body => "{}", :status => 200, :headers => { 'Content-Type' => 'application/json' } }
      else
        { :body => "{}", :status => 400, :headers => { 'Content-Type' => 'application/json' } }
      end
    end

    VCR.turned_off do
      stub_post = stub_request(:post, "https://rspec.api.iij.jp/json").to_return(response)
      client.post(action, params)
      assert_requested(stub_post)
    end
  end
end

describe IIJAPI::Core::QueryClient do
  let(:endpoint) { "https://rspec.api.iij.jp/" }
  let(:access_key) { "0123456789abcdefghij" }
  let(:secret_key) { "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN" }
  let(:api_version) { "2013-09-01" }
  let(:signed_at) { Time.gm(2013, 10, 1) }
  let(:expire_after) { 3600 }
  before do
    Time.stub(:now).and_return(signed_at)
  end

  let(:client) do
    IIJAPI::Core::QueryClient.new(:endpoint => endpoint,
                                  :access_key => access_key,
                                  :secret_key => secret_key,
                                  :api_version => api_version,
                                  :expire_after => expire_after)
  end

  describe '#post' do
    describe "signed with valid signature" do
      context "when simple request" do
        let(:action) { "Test" }
        let(:params) { {} }
        let(:string_to_sign) do
          [
           "POST",
           "rspec.api.iij.jp",
           "/json",
           "APIVersion=#{api_version}&AccessKeyId=#{access_key}&Action=#{action}&Expire=2013-10-01T01%3A00%3A00Z&SignatureMethod=HmacSHA256&SignatureVersion=2"
          ].join("\n")
        end
        it_should_behave_like "valid signature"
      end
    end
  end
end
