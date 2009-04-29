# coding: utf-8

class Word

	attr_accessor :original, :words

	def initialize(lexem)
		parts = lexem.split(/[{}]/)
		@original = parts[0].to_sym
		raw_variants = []
		state, start, i = 0, 0, 0
		parts.last.each_char do |char|
			state = 1 if char == '('
			state = 0 if char == ')'
			if (char == '|' and state == 0)
				raw_variants << parts.last[start...i]
				start = i+1
			end
			raw_variants << parts.last[start...i+1] if i == parts.last.size-1
			i+=1
		end
		words = raw_variants.inject([]){|res, e|
			res << {:original => e.split(/=/).first}
			res
		}

		words.each_with_index do |key, index|
      begin
        words[index][:part_of_speech] = raw_variants[index].split(/[=,]/)[1].to_sym
      rescue
      end
		end

		raw_variants.each_with_index do |variant, index|
			ccase = []
			%w{им род дат вин твор пр}.each do |padej|
				ccase << padej.to_sym unless (variant =~ /#{padej}/).nil?
			end
			words[index][:case] = ccase
		end
		@words = []
		words.each {|e| @words << e if e[:original]['?'].nil?}
	end
end