module Acme
    require 'resolv'

    class Power < Grape::API
        format :json

        helpers do
          include MonitoringHelper
        end

        desc 'Add ip to monitoring'
        params do
            requires :ip, type: String, desc: 'Server ip address', regexp: /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/
        end
        post :monitoring_session do
            monitoring_session = MonitoringSession.where(ip: params[:ip], session_state: 'open').first_or_initialize
            monitoring_session.start_ping
        end

        desc 'Remove ip from monitoring'
        params do
            requires :ip, type: String, desc: 'Server ip address', regexp: /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/
        end
        delete :monitoring_session do
            monitoring_session = MonitoringSession.where(ip: params[:ip], session_state: 'open').try('first')
            if monitoring_session
                monitoring_session.stop_ping
            else
                error!('Open monitoring session with this ip not found', 404)
            end
        end

        desc 'Get monitoring info'
        params do
            requires :ip, type: String, desc: 'Server ip address', regexp: /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/
            requires :monitoring_from, type: DateTime, desc: 'Monitoring info start'
            requires :monitoring_to, type: DateTime, desc: 'Monitoring info end'
        end
        post :monitoring_session_info do
            pings = Ping.where('ping_at >= ? AND ping_at <= ? AND ip = ?', params[:monitoring_from], params[:monitoring_to], params[:ip])
            unless pings.empty?
                status 200
                statistic(pings: pings)
            else
                error!('Such monitoring info not found', 404)
            end
        end
    end
end
