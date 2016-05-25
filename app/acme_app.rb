module Acme
  class App < Goliath::API
    use Goliath::Rack::Params
    use Goliath::Rack::Render
    require 'icmp4em'

    def response(env)
      Acme::API.call(env)
    end
  end
end
