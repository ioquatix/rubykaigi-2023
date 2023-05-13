
# This class is used to get files from the public folder.
class Files
	def initialize(root = File.expand_path('public', __dir__))
		@root = root
	end
	
	def get(path)
		path = File.expand_path(@root + path)
		
		if path.start_with?(@root)
			if File.directory?(path)
				path = File.join(path, 'index.html')
			end
			
			if File.file?(path)
				return File.open(path, 'rb')
			end
		end
		
		return nil
	end
end

FILES = Files.new
