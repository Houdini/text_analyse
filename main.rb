# coding: utf-8

require 'collection'
require 'collections_set'

c  = CollectionsSet.new 'config.yml'


c.set.each_value {|collection| collection.load_data }

#do soft idf
#c.each_value {|collection| collection.idf }

#plot all idf
#c.each_value {|collection| collection.plot :idf }

#do soft ridf
#c.each_value {|collection| collection.ridf }
#c.set.each_value {|collection| collection.plot :ridf }

#c.each_collection do |collection|
#  collection.plot :ridf
#end

#c.each_collection do |collection|
#  collection.phrase! :V, :S
#end

#c.set[:shevardWeek].phrase :V, :S

#c.each_collection do |collection|
#  collection.phrase! :A, :N
#end

# ничего не найдено
#c.each_collection do |collection|
#  collection.phrase! :N, :PR, :N
#end

#c.each_collection do |collection|
#  collection.phrase! :S, :PR, :S
#end

#c.each_collection do |collection|
#  collection.phrase! :N
#end
#
#c.each_collection do |collection|
#  collection.phrase! :S
#end
#
#c.each_collection do |collection|
#  collection.phrase! :A
#end




#c.set[:shevardWeek].load_words
#puts c.set[:shevardWeek].data[:words].class
#c.set[:shevardWeek].data[:words].each_with_index do |word, index|
#  puts "#{index} #{word.original}"
#end

#c.set[:shevardWeek].t_test :A, :N
#c.set[:shevardWeek].t_test :V, :S
c.each_collection do |collection|
  collection.t_test :A, :N
  collection.t_test :V, :S
  collection.t_test :N, :PR, :N
end