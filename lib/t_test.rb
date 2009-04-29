module T_test

  def t_test!(*types)
    puts "t_test: Delete old resuls #{self.data_files[:name]}"
		`rm -rf #{self.data_files[:base_folder] + self.phrase_name('t_test', types)}`
		self.data.delete self.phrase_sym('t_test', types)
		self.t_test(*types)
  end

  def t_test(*types)
    
    self.phrase(*types)
    puts "Starting doing t_test, file: #{self.phrase_name('t_test', types)} for #{self.data_files[:name]}"
    return true unless self.data[self.phrase_sym('t_test',types)].nil?
    data_name = self.phrase_sym('t_test', types)
    phrase_name = self.phrase_sym('phrase', types)
    self.data[data_name] = {}
    return false if self.data[phrase_name].nil?
    total_words = 0
    self.data[:normal_words_amount].each_key{|key| total_words+=self.data[:normal_words_amount][key]}
    self.data[phrase_name].each_key do |key|
    theoretical_prob = 1
      key.to_s.split.each do |word|
        begin
          theoretical_prob *= self.data[:normal_words_amount][word.to_sym]
        rescue
        end
      end
      theoretical_prob /= total_words*total_words
      p = self.data[phrase_name][key]/total_words
      self.data[data_name][key] = (self.data[phrase_name][key]/total_words - theoretical_prob).abs/(Math.sqrt(p*(1-p)/total_words))
    end
    save_hash_to_file self.data[data_name], data_name
  end
end