#!/usr/bin/env ruby

require 'async'
require 'async/io'
require 'async/io/stream'
require_relative '../files'

files = Files.new

Async do
	endpoint = Async::IO::Endpoint.tcp('localhost', 8009)
	
	endpoint.accept do |connection|
		stream = Async::IO::Stream.new(connection)
		method, path = stream.read_until("\r\n").split(/\s+/, 2)
		Console.logger.info(self, "Received #{method} #{path}")
		
		if file = files.get(path)
			Console.logger.info(self, "Serving #{path}")
			connection.write(file.read)
			file.close
		else
			Console.logger.warn(self, "Could not find #{path}")
		end
		
	rescue => error
		Console.logger.error(self, error)
	ensure
		connection.close
	end
end
