module Acme
    require 'resolv'

    class Power < Grape::API
        format :json

        desc 'Add ip to monitoring'
        params do
            requires :ip, type: String, desc: 'Server ip address', regexp: /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/
        end
        post :monitoring_session do
            monitoring_session = MonitoringSession.where(ip: params[:ip], session_state: 'open').first_or_initialize
            if monitoring_session.new_record?
                ping = ICMP4EM::ICMPv4.new(params[:ip], timeout: 60)

                ping.on_success do |host, _seq, latency, _count_to_recovery|
                    # puts "Success, Host #{host}, Latency #{latency}ms"
                    Fiber.new { monitoring_session.pings.create(ping_at: Time.now.getutc, latency: latency, ip: host, ping_status: 'success') }.resume
                end

                ping.on_expire do |host, _seq, _exception, _count_to_failure|
                    # puts "Fail, Host #{host}"
                    Fiber.new { monitoring_session.pings.create(ping_at: Time.now.getutc, ip: host, ping_status: 'failed') }.resume
                end

                ping.schedule
                monitoring_session.instance_id = ping.id
                monitoring_session.save
            end
        end

        desc 'Remove ip from monitoring'
        params do
            requires :ip, type: String, desc: 'Server ip address', regexp: /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/
        end
        delete :monitoring_session do
            monitoring_session = MonitoringSession.where(ip: params[:ip], session_state: 'open').try('first')
            if monitoring_session
                ping = ICMP4EM::ICMPv4.instances[monitoring_session.instance_id]
                ping.present? ? ping.stop : error!(500)
                monitoring_session.session_state = 'close'
                monitoring_session.save
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
            success_pings = pings.success
            failed_pings = pings.failed
            if !pings.empty?
                if !success_pings.empty?
                    latency_array = success_pings.map { |x| x[:latency] }
                    length = latency_array.length

                    mean = (latency_array.sum / length)
                    min = latency_array.min
                    max = latency_array.max

                    sorted = latency_array.sort
                    median = (sorted[(length - 1) / 2] + sorted[length / 2]) / 2.0

                    sample_variance = latency_array.inject(0) { |accum, i| accum + (i - mean)**2 }
                    stdev = Math.sqrt(sample_variance)

                    { mean: mean.round(3), max: max.round(3), min: min.round(3), stdev: stdev.round(3), median: median.round(3), expired: failed_pings.count }
                else
                    { expired: failed_pings.count }
                end
            else
                error!('Such monitoring info not found', 404)
            end
        end
    end
end
