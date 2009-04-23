module Idf

  def idf!
    puts "IDF: Delete old resuls #{self.data_files[:name]}"
		`rm -rf #{self.data_files[:base_folder] + '/idf'}`
		self.data.delete :idf
		self.idf
	end

  #small value -- more trash
	def idf
		return true unless self.data[:idf].nil?

		puts "IDF: Starting for #{self.data_files[:name]}"
		idf = {}
		self.data[:words_per_collection].each_pair do |word, n|
			idf[word] = Math.log self.documents_amount/n
		end
		self.data[:idf] = idf
		save_hash_to_file idf, :idf
	end
  
end