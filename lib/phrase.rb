# coding: utf-8
module Phrase

  def phrase!(*types)
    puts "Phrase: Delete old results #{self.data_files[:name]}, file #{self.phrase_sym('phrase', types)}"
		`rm -rf #{self.data_files[:base_folder] + self.phrase_name('phrase', types)}`
		self.data.delete self.phrase_sym('phrase', types)
		self.phrase('phrase', *types)
  end

  def phrase(*types)
    phrase = self.phrase_sym 'phrase', types
    return true unless self.data[self.phrase_sym('phrase',types)].nil?
    puts "Starting doing phrase file: #{phrase.to_s} for #{self.data_files[:name]}"

    result = {}
    self.each_line_documents do |line|
      temp = search_pattern line, *types
      temp.each_key do |key|
        result.has_key?(key) ? result[key] += 1 : result[key] = 1
      end
    end
    save_hash_to_file result, self.phrase_sym('phrase',types)
  end
end