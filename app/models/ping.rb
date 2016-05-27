class Ping < ActiveRecord::Base
  enum ping_status: [:success,:failed]
  belongs_to :monitoring_session
end
