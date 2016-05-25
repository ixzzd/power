require 'spec_helper'


# describe 'POST /api/monitoring_session' do
#   context 'new listing success' do
#     before do
#       post :create, format: :json, :data {ip: '81.19.82.11'}
#     end
#
#     it 'creates a new listing' do
#       expect(MonitoringSession.last.ip).to eq('81.19.82.11')
#     end
#   end


describe Acme::API do
    include Goliath::TestHelper

    before(:all) do

    end

    # it 'Add ip to monitoring' do
    #     with_api Acme::App do
    #         post_request(path: 'http://0.0.0.0:9090/api/monitoring_session', body: {ip: '81.19.82.11'}) do |async|
    #             async.response_header.status.should == 201
    #         end
    #     end
    # end

    # it 'Remove ip from monitoring' do
    #     with_api Acme::App do
    #         delete_request(path: '/api/monitoring_session') do |async|
    #             expect(async.response).to eq({ ping: 'pong' }.to_json)
    #         end
    #     end
    # end
    #
    # it 'Get monitoring info' do
    #     with_api Acme::App do
    #         get_request(path: '/api/monitoring_info') do |async|
    #             expect(async.response).to eq({ ping: 'pong' }.to_json)
    #         end
    #     end
    # end
end
