# coding: US-ASCII
# frozen_string_literal: false
require 'test/unit'
require 'stringio'
require_relative '../../../lib/net/http'
require_relative 'utils'

class TestInterruptClient < Test::Unit::TestCase
  include TestNetHTTPUtils

  CONFIG = {
    'host' => '127.0.0.1',
    'proxy_host' => nil,
    'proxy_port' => nil,
  }

  def test_interrupted_realserver
    server_pid = fork { exec "ruby test/net/http/echo.rb" }
    at_exit { `kill -s int #{server_pid}`}
    http = Net::HTTP.new('localhost', 8000, nil, nil)

    begin
      sleep 0.1
    end until (http.get('/waiting').body == "waiting" rescue nil)
    sleep 0.1


    outer_loops = 1000
    inner_loops = 100
    outer_loops.times do |j|
      begin
        Timeout.timeout(0.01) do
          inner_loops.times do |i|
            assert_equal (j*outer_loops)+i, http.get("/#{((j*outer_loops)+i).to_s}").body.to_i
          end
          raise "Did not timeout"
        end
      rescue Timeout::Error
      end
    end
  end

  def test_interrupted_proxy
    start do |http|
      outer_loops = 1000
      inner_loops = 100


      outer_loops.times do |j|
        begin
          Timeout.timeout(0.01) do
            inner_loops.times do |i|
              assert_equal (j*outer_loops)+i, http.post("/", "#{((j*outer_loops)+i).to_s}").body.to_i
            end
            raise "Did not timeout"
          end
        rescue Timeout::Error
        end
      end
    end
  end
end
