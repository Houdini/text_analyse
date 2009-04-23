module Phrase

  def phrase_name(types)
    '/phrase'+types.join('_')
  end

  def phrase_sym(types)
    ('phrase'+types.join('_')).to_sym
  end

  def phrase!(*types)
    puts "Phrase: Delete old results #{self.data_files[:name]}"
		`rm -rf #{self.data_files[:base_folder] + phrase_name(types)}`
		self.data.delete phrase_sym(types)
		self.phrase(*types)
  end

  def phrase(*types)
    phrase = phrase_sym types
    return true unless self.data[phrase_sym(phrase)].nil?
    puts "Starting doing phrase file: #{phrase.to_s} for #{self.data_files[:name]}"
    

  end
end