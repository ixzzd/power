require 'rubygems'

ENV['RACK_ENV'] ||= 'test'

require 'rack/test'

require File.expand_path('../../config/environment', __FILE__)

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
  config.raise_errors_for_deprecations!
end

require 'goliath/test_helper'

module Goliath
  module TestHelper
    def with_api(api, options = { :log_stdout => false }, &blk)
      server(api, options.delete(:port) || 9901, options, &blk)
    end
  end
end
