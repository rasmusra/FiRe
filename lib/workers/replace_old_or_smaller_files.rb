require_relative '../helpers/resource_locator'
require_relative './general_worker'
include FiRe



# this worker traverses all items in srcdir and compares with
# corresponding path in each destination directory. If the corresponding
# destination item either does not exist, is older or has size smaller than 
# source item, then a replication is being made and any existing item in  
# destination will be overwritten
class ReplaceOldOrSmallerFiles
  include GeneralWorker
  
  def initialize(params)
    @source = params["source"]
    @destination = params["destination"]
    parseIgnoreList(params)
  end



  # copies all files found in srcdir to all the destdirs but only if dest is not uptodate
  def execute

    copiedCounter = 0
    failedCounter = 0
    skippedCounter = 0
    
    # traverse all srcfiles
    FiRe::filesys.find(@source) { |srcItem|
      
      # give some feedback
      FiRe::log.info "searching #{srcItem}..." if FiRe::filesys.directory?(srcItem)
      
      # skip this subtree if it matches ignored-items
      FiRe::filesys.prune if ignore?(srcItem) 
    
      # transform srcpath to destpath
      destItem = srcItem.gsub(@source, @destination)

      # do not copy if item already exists and looks OK
      if needCopy(destItem,srcItem)
        copyWentWell = copyItem(srcItem, destItem)
        copiedCounter += 1 if copyWentWell
        failedCounter += 1 if !copyWentWell
      else
        skippedCounter += 1 
      end
      
    }
    
    # give some feedback
    FiRe::log.info "copied #{copiedCounter} items, while #{failedCounter} items failed. #{skippedCounter} items did not need to be copied today."

  end

private 

  # handles copying of given srcItem
  def copyItem(srcItem,destItem)
    copyWentWell = false # not yet...

    begin

      # directory?
      FiRe::filesys.mkpath(destItem) if FiRe::filesys.directory?(srcItem)
      
      # file?
      if FiRe::filesys.file?(srcItem)
        FiRe::log.info "#{FiRe::filesys.basename(srcItem)} ----> #{destItem}"
        FiRe::filesys.cp(srcItem, destItem)
      end

      copyWentWell = true

    rescue StandardError => e
      FiRe::log.error e
    end

    copyWentWell

  end


  # this one checks if a destdir needs to be replaced (or created first time)
  def needCopy(destItem,srcItem)
    oldfile = !FiRe::filesys.uptodate?(destItem,srcItem)
    missingfile = !FiRe::filesys.exist?(destItem) || smaller?(destItem,srcItem)

    if !(oldfile || missingfile)
      FiRe::log.debug "item already there! [#{srcItem}]"
    end
    
    oldfile || missingfile
    
  end
  
  
  # returns true if (destsize < srcsize), else false
  def smaller?(destItem, srcItem)

    srcsize = FiRe::filesys.size?(srcItem) 
    destsize = FiRe::filesys.size?(destItem)

    # handle strange behaviour with nil in return for zero-bytes sizes
    srcsize = 0 if srcsize.nil?
    destsize = 0 if destsize.nil?
    
    destsize < srcsize 
    
  end

end
