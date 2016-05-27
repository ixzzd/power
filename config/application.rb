$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'api'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'

Bundler.require :default, ENV['RACK_ENV']

require 'goliath'
require "em-synchrony"
require "em-synchrony/mysql2"
require "em-synchrony/activerecord"

ActiveRecord::Base.establish_connection(:adapter  => 'em_mysql2',
                                        :database => "power_#{ENV['RACK_ENV']}",
                                        :username => 'root',
                                        :host     => 'localhost',
                                        :pool     => 5)

Dir[File.expand_path('../../app/models/*.rb', __FILE__)].each {|f| require f}
Dir[File.expand_path('../../app/helpers/*.rb', __FILE__)].each {|f| require f}
Dir[File.expand_path('../../api/*.rb', __FILE__)].each {|f| require f}

require 'api'
require 'acme_app'
