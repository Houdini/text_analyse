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

c.each_collection do |collection|
  collection.plot :ridf
end