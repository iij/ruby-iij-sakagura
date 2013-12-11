require 'helper'

describe IIJAPI::GP::Client do
  describe "#gp" do
    it "returns IIJAPI::GP::GP with specified gp service code" do
      expect(signed_gp_client.gp('gp00000000').gp_service_code).to eq('gp00000000')
    end
  end

  describe "#gp_service_code_list", :vcr => true do
    it "returns service code list" do
      expect(signed_gp_client.gp_service_code_list).to be_an(Array)
    end
  end
end