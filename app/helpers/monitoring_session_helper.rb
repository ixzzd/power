module MonitoringSessionHelper
  def start_ping
    return nil if !params[:ip]
    ping_machine = ICMP4EM::ICMPv4.new(params[:ip], timeout: 60)

    ping_machine.on_success do |host, _seq, latency, _count_to_recovery|
        Fiber.new { self.pings.create(ping_at: Time.now.getutc, latency: latency, ip: host, ping_status: 'success') }.resume
    end

    ping_machine.on_expire do |host, _seq, _exception, _count_to_failure|
        Fiber.new { self.pings.create(ping_at: Time.now.getutc, ip: host, ping_status: 'failed') }.resume
    end

    ping_machine.schedule
    self.instance_id = ping_machine.id
    self.save
  end

  def stop_ping
    ping = ICMP4EM::ICMPv4.instances[self.instance_id]
    ping.present? ? ping.stop : error!(500)
    self.closed_at = Time.now.getutc
    self.session_state = 'close'
    self.save
  end
end
