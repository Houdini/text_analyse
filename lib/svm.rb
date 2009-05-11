module Svm
require 'svm'

  def svm!

  end

  # parameters
  # 1 - preposition number in text
  # 2 - how many capital words in preposition / number of words
  def svm
    p 'start svm'

    zero_one = []
    signs = []
    positive, negative = 0, 0
    self.each_line_documents 0.5 do |line|
      all = []
      line.split('||').each do |prep|
        all << prep
      end
      for i in (2..all.size-1) do
        next if all[i].length > 3 # if this is real line
        next if all[i].strip.length <1 # if this is null line, specially at the document's end

        positive += 1 if all[i].strip == '+'
        negative += 1 if all[i].strip == '-'
        if negative+10 >= positive
          negative -= 1
          next
        end
        puts "+: #{positive}, -: #{negative}"

        preposition = all[i+1]
        characteristic = []

        zero_one << (all[i].strip == '+' ? 1.0 : -1.0)

        characteristic << i/2 #preposition number
        characteristic << self.capitalized(preposition) #how many capital words in preposition / number of words
        characteristic << self.titled(preposition, all[1]) #is there is word from title
        

        signs << characteristic

      end
    end

#    for i in (0...signs.length-1)
#      puts "#{zero_one[i]} : #{signs[i][0]} #{signs[i][1]} #{signs[i][2]}"
#    end
    p 'start svm training'
    prob = Problem.new(zero_one, signs)
    param = Parameter.new(:kernel_type => LINEAR, :C => 10)
    m = Model.new(prob, param)
    m.save('test.model')
    p 'svm training complete'
  end

  def svm_exam
    m = Model.new('test.model')
    errors = 0
    total = 0
    zero_one = []
    signs = []

    self.each_line_documents do |line|
      all = []
      line.split('||').each do |prep|
        all << prep
      end
      for i in (2..all.size-1) do
        next if all[i].length > 3 # if this is real line
        next if all[i].strip.length <1 # if this is null line, specially at the document's end
        preposition = all[i+1]
        characteristic = []

        zero_one << (all[i].strip == '+' ? 1.0 : -1.0)

        characteristic << i/2 #preposition number
        characteristic << self.capitalized(preposition) #how many capital words in preposition / number of words
        characteristic << self.titled(preposition, all[1]) #is there is word from title

        signs << characteristic
      end
    end

    signs.each_with_index do |sign, index|
      res = m.predict(sign)
      total += 1
      #puts "res: #{res}, real: #{zero_one[index]}"
      errors += 1 if res != zero_one[index]

    end
    puts "Total:#{total}\n Errors: #{errors}\n Right: #{total - errors} "
    
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