#!/usr/bin/env ruby

require 'async'
require 'async/io'
require 'async/io/stream'

Sync do
	endpoint = Async::IO::Endpoint.tcp('localhost', 8010)
	
	ARGV.each do |path|
		endpoint.connect do |connection|
			stream = Async::IO::Stream.new(connection)
			stream.write("GET #{path} HTTP/1.0\r\n\r\n")
			stream.flush
			
			puts stream.read
		end
	end
end
