Dir["lib/*"].each{|file| require file }

class Collection

  include Idf
  include Ridf
  include Phrase

	attr_reader :data_files, :documents_amount
	attr_accessor :data

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
      data_files[:files][file.to_sym] = base_folder + "/#{file}"
    end
		data_files
	end

	def load_data
		@data_files[:files].each_pair do |name, file|
			@data[name] = load_data_from_file(file)
		end
	end


	def load_data_from_file(file)
		res = {}
		IO.readlines(file).each { |line|
			words = line.split
			second = words.last.to_f
			second = (second == 0 ? words.last : second)
			res[words.first.to_sym] = second
		}
		res
	end

	def save_hash_to_file hash, name
		@data_files[:files][name] = @data_files[:base_folder] + "/#{name.to_s}"
		sorted_array = hash.to_a.sort_by{|e| e[1]}.reverse
		sorted_array.each {|e|
			`echo "#{e[0]} #{e[1]}" >> #{@data_files[:files][name]}`
		}
	end

  def plot name
    puts name
    puts self.data_files[:name]
    puts self.data_files[:files][name]
    `python plot.py #{@data_files[:files][name]}`
  end

end
