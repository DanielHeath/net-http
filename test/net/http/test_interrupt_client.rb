# coding: US-ASCII
# frozen_string_literal: false
require 'test/unit'
require 'net/http'
require 'stringio'
require_relative 'utils'

class TestInterruptClient < Test::Unit::TestCase
  include TestNetHTTPUtils

  CONFIG = {
    'host' => '127.0.0.1',
    'proxy_host' => nil,
    'proxy_port' => nil,
  }

  def test_interrupted
    start {|http|
      100.times do
        begin
          Timeout.timeout(0.1) do
            1000.times do |i|
              assert_equal i, http.post('/', i.to_s).body.to_i
            end
          end
        rescue Timeout::Error
        end
      end
    }
  end
end