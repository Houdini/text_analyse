module Ridf
  def ridf!
    puts "RIDF: Delete old resuls #{self.data_files[:name]}"
		`rm -rf #{self.data_files[:base_folder] + '/ridf'}`
		self.data.delete :ridf
		self.ridf
  end

  #bigger amount more interesing words, as they are more unpredictable
  def ridf
		return true unless self.data[:ridf].nil?
		puts "RIDF: Starting for #{self.data_files[:name]}"
    
    lambda_for_words = {}
    self.data[:normal_words_amount].each do |key, value|
      lambda_for_words[key] = value/self.documents_amount
    end

    #1 - poisson law(0, lambda)
    def law(word, lambda_for_word)
      Math.exp lambda_for_word
    end

		ridf = {}
		self.data[:words_per_collection].each_pair do |word, n|
			ridf[word] = -Math.log( (n/self.documents_amount - (1-law(word, lambda_for_words[word]))).abs )
		end
		self.data[:ridf] = ridf
		save_hash_to_file ridf, :ridf
  end
end