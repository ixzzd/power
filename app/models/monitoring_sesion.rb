class MonitoringSession < ActiveRecord::Base
  include MonitoringSessionHelper
  enum session_state: [:open,:close]
  has_many :pings
end
