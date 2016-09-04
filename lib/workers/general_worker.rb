require 'lib/helpers/resource_locator'
include FiRe

module GeneralWorker

private

  # send yml-config for parsing the ignore-list
  def parseIgnoreList(params)
    @ignoreList = []
    @ignoreList = params["ignore"].split(",") unless params["ignore"].nil?
  end

  # checks given item against each ignore-wildcards 
  def ignore?(item)
    @ignoreList.each { |i|
      baseitem = FiRe::filesys.basename(item)
      regexp = convertToRegexp(i)
      if baseitem.match(regexp)
        FiRe::log.debug "ignoring #{item}"
        return true
      end
    }
    false
  end

  def convertToRegexp(wildcard)
    
    # split wildcard in filename and fileextension
    dotIdx = wildcard.rindex(".")
    if dotIdx.nil?
      # only name was given, so any extension will do
      filename = wildcard
      fileExtension = "*"
    else
      filename = wildcard[0,dotIdx]
      fileExtension = wildcard[dotIdx+1,wildcard.length]
    end
    
    # convert name before dot, handle wildcards at start and end
    exp = ""
    exp = "^" unless filename.match(/^\*/)
    exp = exp + filename.gsub(/\*/,"")
    exp = exp + ".*" if filename.match(/\*$/)
    
    # add dot if one was found
    exp = exp + "\."
    
    # handle wildcards at start and end
    exp = exp + ".*" if fileExtension.match(/^\*/)
    exp = exp + fileExtension.gsub(/\*/,"")
    exp = exp + "$" unless fileExtension.match(/\*$/)
   
    Regexp.new(exp)
    
  end
  
end