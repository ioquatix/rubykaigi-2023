#!/usr/bin/env ruby

require 'async'
require 'async/io'
require 'async/io/stream'

Sync do
	endpoint = Async::IO::Endpoint.tcp('localhost', 8009)
	
	ARGV.each do |path|
		endpoint.connect do |connection|
			stream = Async::IO::Stream.new(connection)
			stream.puts("GET #{path}")
			puts stream.read
		end
	end
end
