#!/usr/bin/env ruby

require 'async'
require 'async/http/server'
require 'async/http/endpoint'
require 'async/http/protocol/response'
require_relative '../files'
	
Sync do |task|
	app = lambda do |request|
		if file = FILES.get(request.path)
			Protocol::HTTP::Response[200, {}, [file.read]]
		else
			Protocol::HTTP::Response[404, {}, []]
		end
	end
	
	endpoint = Async::HTTP::Endpoint.parse('http://127.0.0.1:9294')
	server = Async::HTTP::Server.new(app, endpoint)
	
	server.run
end
