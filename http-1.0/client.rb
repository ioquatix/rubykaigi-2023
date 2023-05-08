#!/usr/bin/env ruby

require 'async'
require 'async/io'
require 'async/io/stream'

Sync do
	endpoint = Async::IO::Endpoint.tcp('localhost', 8010)
	
	ARGV.each do |path|
		endpoint.connect do |connection|
			stream = Async::IO::Stream.new(connection)
			stream.write("GET #{path} HTTP/1.0\r\n")
			stream.write("Accept: text/html\r\n")
			stream.write("\r\n")
			stream.flush
			
			response_line = stream.read_until("\r\n")
			version, status, reason = response_line.split(' ', 3)
			Console.logger.info(self, "Received #{version} #{status} #{reason}")
			
			while line = stream.read_until("\r\n")
				break if line.empty?
				name, value = line.split(/:\s*/, 2)
				Console.logger.info(self, "Header #{name}: #{value}")
			end
			
			puts stream.read
		end
	end
end
