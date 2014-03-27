require 'helper'
require 'iij/sakagura/core/middleware/signature_v2'

describe IIJ::Sakagura::Core::Middleware::SignatureV2, type: :request_middleware do
  def middleware_options
    [
     {
       endpoint: endpoint,
       access_key: access_key,
       secret_key: secret_key,
       expire_after: expire_after
     }
    ]
  end

  let(:endpoint) { "https://api.example.jp/json" }
  let(:access_key) { "0123456789abcdefghij" }
  let(:secret_key) { "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN" }
  let(:expire_after) { 3600 }

  before do
    described_class.any_instance.stub(:current_time).and_return( Time.utc(2013, 10, 1) )
  end

  shared_examples_for "valid signature" do
    let(:result) do
      process(:post) do |req|
        req.body = params
      end
    end
    let(:signature) do
      digest = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, secret_key, string_to_sign)
      Base64.encode64(digest).chomp
    end

    it { expect(result[:body]['Signature']).to eq(signature) }
  end

  describe "#call" do
    context "simple request" do
      let(:params) do
        {
          "Action" => "Test",
          "APIVersion" => "20130901"
        }
      end
      let(:string_to_sign) do
        [
         "POST",
         "api.example.jp",
         "/json",
         "APIVersion=20130901&AccessKeyId=#{access_key}&Action=Test&Expire=2013-10-01T01%3A00%3A00Z&SignatureMethod=HmacSHA256&SignatureVersion=2"
        ].join("\n")
      end

      it_should_behave_like "valid signature"
    end

    context "long list param" do
      let(:params) do
        init = {
          "Action" => "Test",
          "APIVersion" => "20130901"
        }
        (1..10).inject(init) {|h, i| h["Param.#{i}"] = i; h }
      end

      let(:string_to_sign) do
        param_str = "Param.1=1&Param.10=10&Param.2=2&Param.3=3&Param.4=4&Param.5=5&Param.6=6&Param.7=7&Param.8=8&Param.9=9"

        [
         "POST",
         "api.example.jp",
         "/json",
         "APIVersion=20130901&AccessKeyId=#{access_key}&Action=Test&Expire=2013-10-01T01%3A00%3A00Z&#{param_str}&SignatureMethod=HmacSHA256&SignatureVersion=2"
        ].join("\n")
      end
      it_should_behave_like "valid signature"
    end
  end
end
