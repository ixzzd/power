module Acme
  class API < Grape::API
    prefix 'api'
    format :json
    mount ::Acme::Power
  end
end
