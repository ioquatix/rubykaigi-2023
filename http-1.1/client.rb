#!/usr/bin/env ruby

require 'async'
require 'async/io'
require 'async/io/stream'

Sync do
	endpoint = Async::IO::Endpoint.tcp('localhost', 8009)
	
	endpoint.connect do |connection|
		stream = Async::IO::Stream.new(connection)
		ARGV.each do |path|
			stream.write("GET #{path} HTTP/1.0\r\n\r\n")
			stream.flush
			
			length = nil
			
			while line = stream.read_until("\r\n")
				break if line.empty?
				
				key, value = line.split(/:\s+/, 2)
				if key.downcase == "content-length"
					length = Integer(value)
				end
			end
			
			if length > 0
				puts stream.read(length)
			end
		end
	end
end
