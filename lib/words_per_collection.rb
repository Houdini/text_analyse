module Words_per_collection
    
  def words_per_collection!
    puts "WORDS_PER_COLLECTION: Удаляем предыдущий результат #{self.data_files[:name]}"
		`rm -rf #{self.data_files[:base_folder] + '/words_per_collection'}`
		self.data.delete :words_per_collection
		self.words_per_collection
  end

  def words_per_collection

    p 'words_per_collection: начало'
    all_words = []
    words_by_size = {}
    each_line_documents do |line|
      line.split(/[\s."«»]/i).each do |token|
        next if token.size < 4
        #p token.split('||').last
        w = Word.new(token.split('||').last)
        w.words.each do |normal_word|
          if words_by_size.has_key?(normal_word[:original])
            words_by_size[normal_word[:original]] += 1
          else
            words_by_size[normal_word[:original]] = 1
          end
        end
      end
      
    end
    save_hash_to_file words_by_size, :words_per_collection
    
  end

end
