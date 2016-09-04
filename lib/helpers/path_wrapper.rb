require 'Find'
require 'FileUtils'


# the need for this wrapper comes from the different pathseparators on different os
class PathWrapper < String

  def initialize(path)

    # UNC's not allowed
    if RUBY_PLATFORM =~ /mswin/ && path.match(/^\\\\/)  
      raise ArgumentException, "UNC paths [#{path}] not supported"
    end

    # turn backslashes to slashes
    path.gsub!(/\\/,"/") if path.match(/\\/)
    
    # we need a trailing slash if we have a rootdir
    path.sub!(/:/,":\/") if path.match(/^\w:$/)

    super(path)

  end
end