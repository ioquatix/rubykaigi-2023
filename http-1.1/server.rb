#!/usr/bin/env ruby

require 'async'
require 'async/io'
require 'async/io/stream'
require_relative '../files'

Sync do
	endpoint = Async::IO::Endpoint.tcp('localhost', 8011)
	
	endpoint.accept do |connection|
		stream = Async::IO::Stream.new(connection)
		while request_line = stream.read_until("\r\n")
			method, path, version = request_line.split(/\s+/, 3)
			Console.logger.info(self, "Received #{method} #{path} #{version}")
			
			while line = stream.read_until("\r\n")
				break if line.empty?
				name, value = line.split(/:\s*/, 2)
				Console.logger.info(self, "Header #{name}: #{value}")
			end
			
			if file = FILES.get(path)
				Console.logger.info(self, "Serving #{path}")
				stream.write("HTTP/1.1 200 OK\r\n")
				stream.write("Content-Type: text/html\r\n")
				
				body = file.read
				
				stream.write("Content-Length: #{body.bytesize}\r\n")
				stream.write("\r\n")
				stream.write(body)
			else
				Console.logger.warn(self, "Could not find #{path}")
				stream.write("HTTP/1.1 404 Not Found\r\n")
				stream.write("Content-Length: 0\r\n")
				stream.write("\r\n")
			end
			
			stream.flush
		end
	rescue => error
		Console.logger.error(self, error)
		break
	ensure
		connection.close
	end
end
