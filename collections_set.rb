# coding: utf-8
require 'yaml'
class CollectionsSet

  attr_accessor :set

  def initialize config_file
    @set = {}
    config = YAML::load File.open(config_file)
    config.each_key do |name|
      @set[name.to_sym] = Collection.new config[name]['work_files'], config[name]['mystem_passed_collection']
    end
  end

  def each_collection &block
    @set.each_value do |collection|
      block.call(collection)
    end
  end
end