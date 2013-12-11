require 'helper'

describe IIJAPI::GP::GP do
  subject do
    client = IIJAPI::GP::Client.new(:endpoint => 'https://gp-stg.api.iij.jp',
                                    :access_key => test_access_key,
                                    :secret_key => test_secret_key)
    client.gp(test_gp_service_code)
  end

  describe "#service_code_list", :vcr => true do
    let(:response) do
      subject.service_code_list
    end

    it { expect(response).to be_a(Hash) }
    it { expect(response['GcServiceCodeList']).to be_an(Array) }
  end
end
