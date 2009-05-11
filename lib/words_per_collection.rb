module Words_per_collection
    
  def words_per_collection!
    puts "WORDS_PER_COLLECTION: Delete old resuls #{self.data_files[:name]}"
		`rm -rf #{self.data_files[:base_folder] + '/words_per_collection'}`
		self.data.delete :words_per_collection
		self.words_per_collection
  end

  def words_per_collection
    
  end

end
