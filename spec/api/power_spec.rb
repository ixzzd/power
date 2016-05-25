require 'spec_helper'

describe Acme::API do
    include Goliath::TestHelper

    it 'Add wrong ip to monitoring' do
        ip = [rand(26).chr, rand(256), rand(26).chr, rand(256)].join('.')
        with_api Acme::App do
            post_request(path: '/api/monitoring_session', body: {ip: ip}) do |async|
              expect(async.response).to eq({"error":"ip is invalid"}.to_json)
            end
        end
    end

    it 'Add correct ip to monitoring' do
        with_api Acme::App do
            post_request(path: '/api/monitoring_session', body: {ip: '81.19.82.11'}) do |async|
                last_session = MonitoringSession.last
                expect(last_session.ip).to eq('81.19.82.11')
                expect(last_session.session_state).to eq('open')
            end
        end
    end

    it 'Remove wrong ip to monitoring' do
        ip = [rand(256), rand(256), rand(256), 6].join('.')
        with_api Acme::App do
            delete_request(path: '/api/monitoring_session', body: {ip: ip}) do |async|
              expect(async.response).to eq({"error":'Open monitoring session with this ip not found'}.to_json)

            end
        end
    end

    it 'Remove correct ip from monitoring' do
      with_api Acme::App do
          delete_request(path: '/api/monitoring_session', body: {ip: '81.19.82.11'}) do |async|
              session = MonitoringSession.where(ip: '81.19.82.11').first
              expect(session.session_state).to eq('close')
          end
      end
    end

    it 'Get blank monitoring info' do
      with_api Acme::App do
          post_request(path: '/api/monitoring_session_info', body: {ip: '81.19.82.11', monitoring_from:'2015-05-24 06:03:21', monitoring_to:'2015-05-28 06:03:21'}) do |async|
              expect(async.response).to eq({"error": "Such monitoring info not found"}.to_json)
          end
      end
    end

    it 'Get monitoring info with correct dates' do
      ip1 = Array.new(4){rand(256)}.join('.')
      ip2 = Array.new(4){rand(256)}.join('.')
      Ping.create(latency: 65.114, ip: ip1, ping_at: '2016-05-25 06:03:21', ping_status: 'success')
      Ping.create(latency: 4.128, ip: ip1, ping_at: '2016-05-25 06:03:22', ping_status: 'success')
      Ping.create(latency: 4.638, ip: ip1, ping_at: '2016-05-25 06:03:23', ping_status: 'success')
      Ping.create(latency: 11.35, ip: ip1, ping_at: '2016-05-25 06:03:24', ping_status: 'success')
      Ping.create(ip: ip1, ping_at: '2016-05-25 06:03:25', ping_status: 'failed')
      Ping.create(ip: ip2, ping_at: '2016-05-25 06:03:25', ping_status: 'failed')
      Ping.create(ip: ip2, ping_at: '2016-05-28 06:03:2', ping_status: 'failed')
      with_api Acme::App do
          post_request(path: '/api/monitoring_session_info', body: {ip: ip1, monitoring_from:'2016-05-24 06:03:21', monitoring_to:'2016-05-28 06:03:21'}) do |async|
              expect(async.response).to eq({"mean":21.308,"max":65.114,"min":4.128,"stdev":50.904,"median":7.994,"expired":1}.to_json)
          end
      end
      with_api Acme::App do
        post_request(path: '/api/monitoring_session_info', body: {ip: ip2, monitoring_from:'2016-05-24 06:03:21', monitoring_to:'2016-05-28 06:03:21'}) do |async|
            expect(async.response).to eq({"expired":2}.to_json)
        end
      end
    end
end
