#!/usr/bin/env ruby

require 'async'
require 'async/http/internet/instance'
	
Async do |task|
	internet = Async::HTTP::Internet.instance
		
	ARGV.each do |url|
		response = internet.get(url)
		puts response.read
	ensure
		response.close
	end
end
