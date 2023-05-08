#!/usr/bin/env ruby

require 'async'
require 'async/io/stream'
require 'async/http/endpoint'
require 'protocol/http2/client'

CLIENT_SETTINGS = {
	::Protocol::HTTP2::Settings::ENABLE_PUSH => 0,
	::Protocol::HTTP2::Settings::MAXIMUM_FRAME_SIZE => 0x100000,
	::Protocol::HTTP2::Settings::INITIAL_WINDOW_SIZE => 0x800000,
}

Sync do
	endpoint = Async::HTTP::Endpoint.parse("http://localhost:8020")
	connection = endpoint.connect
	framer = Protocol::HTTP2::Framer.new(connection)
	client = Protocol::HTTP2::Client.new(framer)
	
	client.send_connection_preface(CLIENT_SETTINGS)
	
	ARGV.each do |path|
		stream = client.create_stream
		
		headers = [
			[":scheme", endpoint.scheme],
			[":method", "GET"],
			[":authority", "localhost"],
			[":path", path],
			["accept", "*/*"],
		]
		
		stream.send_headers(nil, headers, Protocol::HTTP2::END_STREAM)
		
		def stream.process_headers(frame)
			headers = super
			Console.logger.info(self, "Headers: #{headers}")
		end
		
		def stream.process_data(frame)
			if data = super
				$stdout.write(data)
			end
		end
	
		until stream.closed?
			client.read_frame
		end
	end
	
	client.send_goaway
end
