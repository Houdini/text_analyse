module Idf

  def idf!
    puts "IDF: Delete old resuls #{self.data_files[:name]}"
		`rm -rf #{self.data_files[:base_folder] + '/idf'}`
		self.data.delete :idf
		self.idf
	end

	def idf
    p self.data
		return true unless self.data[:idf].nil?
		puts "IDF: Starting for #{self.data_files[:name]}"

    idf_temp = self.word_document_hash
    idf = {}
    idf_temp.keys.each do |key|
      key.words.each{|w| idf[w[:original]] = 0}
    end
    idf_temp.keys.each do |key|
      key.words.each{|w| idf[w[:original]] += 1 }
    end
    idf.keys.each do |key|
      idf[key] = self.documents_amount if idf[key] > self.documents_amount
    end

    idf.keys.each do |key|
      idf[key] =idf[key].to_f/self.documents_amount
    end
    
		self.data[:idf] = idf
		save_hash_to_file idf, :idf
    p 'end'
	end
  
end