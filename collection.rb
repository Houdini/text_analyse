# coding: utf-8
require 'word'
Dir["lib/*"].each{|file| require file }

class Collection

  include Idf
  include Ridf
  include Phrase
  include T_test
  include Svm

	attr_reader :data_files, :documents_amount
	attr_accessor :data
# base folder where final data
# orginial where all collection
	def initialize(base_folder, original_folder)
		@data_files = detect_data_files(base_folder, original_folder)
		@data = {}
		@documents_amount = Dir[original_folder + '/*'].size.to_f
	end

	def detect_data_files(base_folder, original_data_folder)
		data_files = {}
		data_files[:original_folder] = original_data_folder
		data_files[:base_folder] = base_folder
		data_files[:name] = base_folder.split('/').last.to_sym
		data_files[:files] = {}

		files = Dir[data_files[:base_folder]+'/*'].map{|name| name.split('/').last }
    files.each do |file|
      data_files[:files][file.to_sym] = base_folder + "/#{file}" unless file == 'data'
    end

    data_files[:words_path] = data_files[:base_folder] + "/data"

		data_files
	end

	def load_data
		@data_files[:files].each_pair do |name, file|
			@data[name] = load_data_from_file(file)
		end
	end

  def do_words
    @data[:words] = []
    each_line_documents do |line|
      line.split(/[\s."]/i).each do |token|
        next if token.size < 4
        @data_files[:words] << Word.new(token)#.mb_chars.downcase
      end
    end
    save_words
  end

  def load_words
    return true unless @data[:words].nil?
    res = Object.new
    puts res.class
    File.open(@data_files[:words_path]) { |f| res = Marshal.load(f) }
    puts res.class
    @data[:words] = res
    puts @data[:words].class
    puts @data[:words].first.original
    puts "size is: #{@data[:words].size}"
  end

  def save_words
    `rm -rf #{@data_files[:words_path]}`
    puts  @data_files[:base_folder]
    File.open(@data_files[:words_path], 'w') {|f| f.puts Marshal.dump(@data_files[:words]) }
  end

	def load_data_from_file(file)
		res = {}
		File.read(file).lines.each { |line|
			words = line.split
			second = words.last.to_f
			second = (second == 0 ? words.last : second)
			res[(words[0...words.size-1]).join(' ').to_sym] = second
		}
		res
	end

  def each_line_documents amount=100, &block
    all_files = Dir[@data_files[:original_folder]+'/*']
    all_files.each_with_index do |file, index|
      File.read(file).lines.each do |line|
        block.call(line)
      end
      break if (index.to_f+1)/all_files.size > amount
      #p "max: #{amount}, index%: #{(index.to_f+1)/all_files.size}"
    end
    all_files
  end

  def each_line_document &block
    file = Dir[@data_files[:original_folder]+'/*'].first
    puts file
      File.read(file).lines.each do |line|
        block.call(line)
      end
  end

  def parse_for_word_parts(line)
    result = []
    line.scan(/[\w+]+{[\w+]+\??=[\w]/i).each do |token|
      token_result = []
      token.split(/[{\?=]/).each_with_index do |e, i|
        token_result << e if e.size >= 1
      end
      
      case token_result[1]
        when 'длить' then
          result << ['для', 'для', :PR]
        when 'и' then
          result << ['и', 'и', :CONJ]
        when /[\w]+/ then
          token_result[2] = token_result[2].to_sym
          result << token_result
      end
    end
    result
  end

  def search_pattern where, *patterns
    raw_array = parse_for_word_parts where
    result = {}
    for i in 0...(raw_array.size - patterns.size + 1)
      matched = true
      for j in 0...patterns.size
        if raw_array[i+j].last != patterns[j]
          matched = false
          next
        end
      end
      
      if matched
        pattern_string = ''
        for j in 0...patterns.size
          pattern_string << raw_array[i+j][1]
          pattern_string << ' ' if j != patterns.size - 1
        end
        result.has_key?(pattern_string) ? result[pattern_string] += 1 : result[pattern_string] = 1
      end

    end
    result
  end

	def save_hash_to_file hash, name
    if hash.size > 0
      @data_files[:files][name] = @data_files[:base_folder] + "/#{name.to_s}"
      puts "Writing file #{name.to_s}"
      sorted_array = hash.to_a.sort_by{|e| e[1]}.reverse
      File.open(@data_files[:files][name], 'w') do |f|
        sorted_array.each {|e| f.puts "#{e[0]} #{e[1]}"}
      end
    end
    puts ''
	end

  def plot name
    puts name
    puts self.data_files[:name]
    puts self.data_files[:files][name]
    `python plot.py #{@data_files[:files][name]}`
  end

  def phrase_name(name, *types)
    "/#{name}_"+types.join('_')
  end

  def phrase_sym(name, *types)
    ("#{name}_"+types.join('_')).to_sym
  end


end
