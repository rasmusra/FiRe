require 'Find'
require 'fileutils'


# the need for this wrapper comes from the different pathseparators on different os
class PathWrapper < String

  def initialize(path)

    # UNC's not allowed
    if path.match(/^\\\\/)  
      raise ArgumentException, "UNC paths [#{path}] not supported"
    end
    

    # turn backslashes to slashes
    path.gsub!(/\\/,"/") if path.match(/\\/)
    
    # we need a trailing slash if we have a rootdir
    path.sub!(/:/,":\/") if path.match(/^\w:$/)

    super(path)

  end
end