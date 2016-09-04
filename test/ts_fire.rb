require 'rubygems'
require 'log4r/yamlconfigurator'
require 'Find'
require 'FileUtils'

# this one aids us in not having to maintain a testlist
Find.find(File.expand_path("test")) do |item|
  
  filename = File.basename(item)
  
  # skip this one if not matching "tc_.*.rb"
  next if !filename.match(/#{"^tc_.*\.rb$"}/)
  
  # parse out the lib from full path
  libpath = File.dirname(item).sub("#{FileUtils.pwd}/","")
  testfile = filename.sub(/\.rb$/,"")
  
  # run the tests therein
  require File.join(libpath,testfile) 
  
end
