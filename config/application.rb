$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'api'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'

Bundler.require :default, ENV['RACK_ENV']

Dir[File.expand_path('../../api/*.rb', __FILE__)].each do |f|
  require f
end

require 'goliath'
require "em-synchrony"
require "em-synchrony/mysql2"
require "em-synchrony/activerecord"
require 'api'
require 'acme_app'

ActiveRecord::Base.establish_connection(:adapter  => 'em_mysql2',
                                        :database => "power_#{ENV['RACK_ENV']}",
                                        :username => 'root',
                                        :host     => 'localhost',
                                        :pool     => 5)
class MonitoringSession < ActiveRecord::Base
  enum session_state: [:open,:close]
  has_many :pings
end

class Ping < ActiveRecord::Base
  enum ping_status: [:success,:failed]
  belongs_to :monitoring_session
end

## Close opened sessions
MonitoringSession.open.each do |ms|
  last_ping = ms.pings.try('last').try('ping_at')
  ms.closed_at = last_ping || ms.opened_at
  ms.session_state = 'close'
  ms.save
end
