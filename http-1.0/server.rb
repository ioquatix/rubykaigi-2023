#!/usr/bin/env ruby

require 'async'
require 'async/io'
require 'async/io/stream'
require_relative '../files'

files = Files.new

Sync do
	endpoint = Async::IO::Endpoint.tcp('localhost', 8010)
	
	endpoint.accept do |connection|
		stream = Async::IO::Stream.new(connection)
		method, path, version = stream.read_until("\r\n").split(/\s+/, 3)
		Console.logger.info(self, "Received #{method} #{path} #{version}")
		
		while line = stream.read_until("\r\n")
			break if line.empty?
			name, value = line.split(/:\s*/, 2)
			Console.logger.info(self, "Header: #{name} = #{value}")
		end
		
		if file = FILES.get(path)
			Console.logger.info(self, "Serving #{path}")
			stream.write("HTTP/1.0 200 OK\r\n")
			stream.write("Content-Type: text/html\r\n")
			stream.write("\r\n")
			stream.write(file.read)
			file.close
		else
			Console.logger.warn(self, "Could not find #{path}")
			stream.write("HTTP/1.0 404 Not Found\r\n")
			stream.write("\r\n")
		end
		
		stream.flush
	rescue => error
		Console.logger.error(self, error)
	ensure
		connection.close
	end
end
