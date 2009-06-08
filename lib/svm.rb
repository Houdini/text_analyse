module Svm
require 'svm'
require 'yaml'

  def svm!

  end

  def tf
    tf = {}
    self.get_words_by_file.keys.each do |document|
      collapsed = {}
      passed = []
      self.get_words_by_file[document].each do |word|
        next if passed.include?(word)
        passed << word
        n = array_has_key self.get_words_by_file[document], word
        word.words.each{|w| collapsed.has_key?(w[:original])? collapsed[w[:original]] += 1 : collapsed[w[:original]] = 1}
      end
      p 'start'
      p collapsed[k].to_f
      p self.get_words_by_file[document].size
      p 'end123'
      collapsed.keys.each{|k| collapsed[k] = collapsed[k].to_f/self.get_words_by_file[document].size }
      tf[document] = collapsed
      
    end
    p self.data_files[:name]
    File.open("tf_#{self.data_files[:name]}", 'w') {|f| f.puts Marshal.dump(tf) }
  end

    def count_tf_idf_for_preposition(file, prep, tf_v)

      words_in_prep = []
      prep.split(/[\s."«»]/i).each do |token|
        next if token.size < 4
        words_in_prep << Word.new(token)
      end
      sum = 0
      words_in_prep.each do |word|
        begin
          next if word.words.size == 0
          sum += tf_v[file][word.words.first[:original]]/self.data[:idf][word.words.first[:original].to_sym]
        rescue
        end
      end
      sum
    end

    def number_of_words(preposition)
      preposition.split(' ').size
    end

    def numbers_in_(preposition)
      sum = 0
      preposition.gsub(/[\D]/, '').size
    end

  # parameters
  # 1 - preposition number in text
  # 2 - how many capital words in preposition / number of words
  def svm

    p 'start svm'
    tf_loaded = Object.new
    File.open("tf_#{self.data_files[:name]}") { |f| tf_loaded = Marshal.load(f) }
    idf = self.idf

    zero_one = []
    signs = []
    positive, negative = 0, 0
    self.each_line_documents_with_file 0.8 do |line, file|
      all = []
      line.split('||').each do |prep|
        all << prep
      end
      for i in (6..all.size-1) do
        next if all[i].length > 3 # if this is real line
        next if all[i].strip.length <1 # if this is null line, specially at the document's end

        positive += 1 if all[i].strip == '+'
        negative += 1 if all[i].strip == '-'
        if negative+400 >= positive
          negative -= 1
          next
        end
        #puts "+: #{positive}, -: #{negative}"
        preposition = all[i+1]
        characteristic = []

        zero_one << (all[i].strip == '+' ? 1.0 : -1.0)
        
        characteristic << (i/2).to_f/(all.size/2-1).to_f #preposition number
        characteristic << self.capitalized(preposition) #how many capital words in preposition / number of words
        characteristic << self.titled(preposition, all[1]) #is there is word from title
        characteristic << self.number_of_words(preposition)
        characteristic << self.numbers_in_(preposition)
        characteristic << count_tf_idf_for_preposition(file, preposition, tf_loaded) #tf idf
        signs << characteristic
        #p characteristic

      end
    end

#    for i in (0...signs.length-1)
#      puts "#{zero_one[i]} : #{signs[i][0]} #{signs[i][1]} #{signs[i][2]}"
#    end
    p 'start svm training'
    kernel = LINEAR
    kernel_s = 'LINEAR'
    prob = Problem.new(zero_one, signs)
    param = Parameter.new(:kernel_type => kernel, :C => 5)
    m = Model.new(prob, param)
    m.save('test.model_new_'+kernel_s)
    p 'svm training complete'
  end

  def svm_exam
    kernel = 'LINEAR'
    m = Model.new('test.model_new_'+kernel)
    tf_loaded = Object.new
    File.open("tf_#{self.data_files[:name]}") { |f| tf_loaded = Marshal.load(f) }

    errors = 0
    total = 0
    zero_one = []
    signs = []

    all_files = Dir[@data_files[:original_folder]+'/*']
    all_files.each_with_index do |file, index|

      all = []

      File.read(file).lines.each do |line|
        line.split('||').each do |prep|
          all << prep
        end
      end

      for i in (6..all.size-1) do
        next if all[i].length > 3 # if this is real line
        next if all[i].strip.length <1 # if this is null line, specially at the document's end
        preposition = all[i+1]
        characteristic = []

        zero_one << (all[i].strip == '+' ? 1.0 : -1.0)

        characteristic << (i/2).to_f/(all.size/2-1).to_f #preposition number
        characteristic << self.capitalized(preposition) #how many capital words in preposition / number of words
        characteristic << self.titled(preposition, all[1]) #is there is word from title
        characteristic << self.number_of_words(preposition)
        characteristic << self.numbers_in_(preposition)
        characteristic << count_tf_idf_for_preposition(file, preposition, tf_loaded)
        signs << [characteristic, index, i, zero_one.last]#signs, file_number, prep index, real value
        #p characteristic
      end
    end

    by_file = signs.group_by{|i| i[1] }
    by_file.keys.each do |file_key| #go by every file

      temp = [] # we store files for final result
      by_file[file_key].each do |prep_signs| #predict all results, add to end
        prep_signs << m.predict(prep_signs[0])
        temp << prep_signs if prep_signs.last == 1
      end

      begin
        p by_file[file_key]
        how_many = (by_file[file_key].group_by{|i| i[3] })[1.0].size+2
      rescue
        p 'rescur'
        how_many = 2
      end

      result = "#{all_files[file_key].split('/').last} 1 2 "
      res_int = [1, 2]
      p "max: #{how_many}"
      temp #= temp[0..how_many-1]
      temp = temp.sort_by{|i| i[0].last} #sort_by_tf*idf
      temp.each_with_index do |best, index|
        res_int << best[2]/2
        if best[3] == 1
          result += "#{best[2]/2}+ "
        else
          result += "#{best[2]/2} "
        end
        #p best
      end
      p all_files[file_key]
      p how_many, res_int
      res_int = res_int.sort[0..how_many-1]
      p res_int
      #`rm -rf svm_result_#{kernel.to_s}`
      File.open("svm_result_TEST_#{kernel}", 'a'){|out| out.puts(result)}
      File.open("svm_result_#{kernel}", 'a'){|out| out.puts(all_files[file_key].split('/').last + ' ' +res_int.sort.join(' '))}
      
      #`echo "#{result}" >> svm_result_#{kernel.to_s}`

    end

#    signs.each_with_index do |sign, index|
#      res = m.predict(sign)
#      total += 1
#      puts "res: #{res}, real: #{zero_one[index]}, predict: #{m.predict_values_raw(sign)}"
#      errors += 1 if res != zero_one[index]
#    end
#    puts "Total:#{total}\n Errors: #{errors}\n Right: #{total - errors} "
#
  end

  def titled(line, title)
    words_in_line = get_words(line)
    words_in_title = get_words(title)
    res = 0
    words_in_title.each do |title_word|
      words_in_line.each do |word_title|
        res += 1 if Word.is_same? title_word, word_title
      end
    end
    res
  end

  def capitalized(line)
    return nil if line.nil?
    words_in_line = get_words(line)
    cap = 0
    words_in_line.each do |word|
      cap += 1 if word.capitalized?
    end
 #   p "Total words #{words_in_line.size}"
#    p "capitilized_words: #{cap}"
    cap.to_f/words_in_line.size
  end

  def get_words(line)
    words_in_line = []
    begin
      line.split(/[\s.\-"]/i).each do |token|
        next if token.size < 4
        words_in_line << Word.new(token)
      end
    rescue
    end
    words_in_line
  end
end