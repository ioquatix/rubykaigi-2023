class FanOutWorker < ApplicationWorker
	def perform(urls)
		Sync do
			internet = Async::HTTP::Internet.instance
			
			tasks = urls.map do |url|
				task.async do
					response = internet.get(url)
					[url, response.read]
				ensure
					response.close
				end
			end
			
			responses = tasks.map(&:wait)
			# ... do something with responses ...
		end
	end
end
