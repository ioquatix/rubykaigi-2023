#!/usr/bin/env ruby

require 'async'
require 'async/http/client'
require 'async/http/endpoint'
	
Async do |task|
	endpoint = Async::HTTP::Endpoint.parse('http://127.0.0.1:9294')
	client = Async::HTTP::Client.new(endpoint)
	
	ARGV.each do |path|
		response = client.get(path)
		puts response.read
	ensure
		response.close
	end
end
