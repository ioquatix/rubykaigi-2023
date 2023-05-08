#!/usr/bin/env ruby

require_relative '../files'

require 'async'
require 'async/io/stream'
require 'async/http/endpoint'
require 'protocol/http2/client'

SERVER_SETTINGS = {
	::Protocol::HTTP2::Settings::MAXIMUM_CONCURRENT_STREAMS => 128,
	::Protocol::HTTP2::Settings::MAXIMUM_FRAME_SIZE => 0x100000,
	::Protocol::HTTP2::Settings::INITIAL_WINDOW_SIZE => 0x800000,
	::Protocol::HTTP2::Settings::ENABLE_CONNECT_PROTOCOL => 1,
}

Sync do
	endpoint = Async::HTTP::Endpoint.parse("http://localhost:8020")
	endpoint.accept do |connection|
		framer = Protocol::HTTP2::Framer.new(connection)
		server = Protocol::HTTP2::Server.new(framer)
		
		server.read_connection_preface(SERVER_SETTINGS)
		
		def server.accept_stream(stream_id)
			super.tap do |stream|
				def stream.process_headers(frame)
					headers = super.to_h
					Console.logger.info(self, "Received #{headers}")
					
					path = headers[':path']
					
					if file = FILES.get(path)
						Console.logger.info(self, "Serving #{path}")
						self.send_headers(nil, [
							[":status", "200"],
							["content-type", "text/html"],
						])
						
						self.send_data(file.read, Protocol::HTTP2::END_STREAM)
						file.close
					else
						Console.logger.warn(self, "Could not find #{path}")
						self.send_headers(nil, [
							[":status", "404"],
						], Protocol::HTTP2::END_STREAM)
					end
				end
			end
		end
		
		while frame = server.read_frame
			break if server.closed?
		end
	end
end
