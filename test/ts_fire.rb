require 'rubygems'
require 'log4r/yamlconfigurator'
require 'Find'
require 'FileUtils'

# this one aids us in not having to maintain a testlist
Find.find(File.expand_path("test")) do |item|
  
  filename = File.basename(item)
  
  # skip this one if not matching "tc_.*.rb"
  next if !filename.match(/#{"^tc_.*\.rb$"}/)
  
  # parse out the relative lib from full path
  filePath = File.expand_path(File.dirname(__FILE__))
  relativeLibPath = File.dirname(item).sub("#{filePath}/","")
  testfile = filename.sub(/\.rb$/,"")
  
  # run the tests therein
  require_relative File.join(relativeLibPath,testfile) 
  
end
