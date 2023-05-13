#!/usr/bin/env ruby

require 'async'
require 'async/http/internet/instance'
	
Async do |task|
	internet = Async::HTTP::Internet.instance
	
	tasks = ARGV.map do |url|
		task.async do
			response = internet.get(url)
			[url, response.read]
		ensure
			response.close
		end
	end
	
	responses = tasks.map(&:wait)
	
	responses.each do |url, body|
		puts "#{url}: #{body}"
	end
end
