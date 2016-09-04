require 'lib/helpers/filesys_proxy'
require 'lib/helpers/filesys_win'
require 'log4r'


# this module can be included for getting shortnames 
# for example: 'filesys' instead of 'ResourceLocator.getFilesystem'
module FiRe

  # alias for ResourceLocator.getFilesystem
  def filesys
    ResourceLocator.getFilesystem
  end
  
  # alias for ResourceLocator.getLog
  def log
    ResourceLocator.getLog
  end
  
end


# implementes the Locator-pattern. Breaks dendencies to classes that touches 
# the filesystem, i.e. provides a testseam for testing purposes. You might
# want to include the FiRe-module in lib 'fire_shortnames' instead of accessing 
# this class directly.
class ResourceLocator
  private_class_method :new
  
  @@filesys = nil
  @@log = nil


  # usable when a reset is needed
  def ResourceLocator.init
    @@filesys = nil
    @@log = nil
  end
  
  def ResourceLocator.getFilesystem
    @@filesys = createFilesys if @@filesys.nil?
    @@filesys
  end
  
  def ResourceLocator.setFilesystem(filesys)
    @@filesys = filesys
  end
  
  def ResourceLocator.getLog
    if @@log.nil?
      @@log = Log4r::Logger.new("outofthebox")
      @@log.add Log4r::Outputter.stdout
      @@log.level = Log4r::FATAL
      @@log
    end
    @@log 
  end
  
  def ResourceLocator.setLog(log)
    @@log = log
  end
  
private

  def ResourceLocator.createFilesys
    if RUBY_PLATFORM =~ /mswin/
      FilesysWin.new
    else
      FilesysProxy.new
    end
  end
end


