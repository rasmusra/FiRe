require 'lib/helpers/resource_locator'
require 'lib/workers/general_worker'
include FiRe



# Use this worker to move backup to history-backup. The oldest history-backup
# is overwritten if history is full. The paramerer 'history' states how many 
# history-backups should be maintained.
# example: I want 7 backups kept with rolling backups.
class RollingBackup
  include GeneralWorker
  
  
  def initialize(params)
    @history = params["history"]
    @destination = params["destination"]
    @backupDirFlag = "rolling backup"
    parseIgnoreList(params)
  end


  # removes all files from destdir that is not found in srcdir
  def execute
    
    newBackup = FiRe::filesys.join(@destination, createBackupDirName)
    FiRe::filesys.mkpath newBackup

    FiRe::filesys.find(@destination) { |item|
      
      # prune this branch if it should be ignored or if it is a backup-dir
      FiRe::filesys.prune if ignore?(item) || backupdirectory?(item)
      
      # if item is in rootdir then we should move it. This will make all items 
      # being moved eventually since we're starting from top'
      if inDestinationRootDir?(item)
        FiRe::filesys.mv(item, newBackup)  
        FiRe::filesys.prune
      end

    }

    deleteBackupsThatIsTooOld

  end


private


  # returns true if item is in destination-dirs rootdir
  def inDestinationRootDir?(item)
    # the dirname-func returns "/" if "/" is given as dir,
    # therefore we need to check that item is not equal to @destination
    item != @destination && FiRe::filesys.dirname(item) == @destination
  end


  # this one constructs the dirname for a backup, appending datetime to backup-dir-flag
  def createBackupDirName
    
    # get timestamp on the format 'yyyy-mm-dd hh:mm:ss'
    timestamp = DateTime.now.to_s.sub("T"," ").sub(/\+.*$/,"").gsub(":","")
    
    "#{@backupDirFlag} #{timestamp}"    
  
  end
  

  # this one sorts all backupdirs and deletes the ones that is too old,
  # comparing against configured history-limit
  def deleteBackupsThatIsTooOld
    backupdirs = []

    # get all backupdirs found
    FiRe::filesys.find("#{@destination}") { |item|
      if backupdirectory?(item)
        backupdirs.push(item)
        FiRe::log.debug "found another backupdirectory: #{item}"
        FiRe::filesys.prune
      end
    }

    # sort dirs in a way so that oldest comes first
    backupdirs = backupdirs.sort { |x,y| y<=>x }
    
    # if there are too many of those backup-dirs we need to get rid of oldest
    until backupdirs.length <= @history
      dir = backupdirs.pop
      removeBackup(dir) 
    end
  
  end

  
  # this one removes given directory recursively persistently without confirmation
  def removeBackup(dir)
    FiRe::log.info "removing rolling backup-directory #{dir}"
    FiRe::filesys.rm_rf(dir)
  end
  
  
  # this one returns true if given directory's name fulfills naming convention for a
  # rolling backup directory. The rolling backups has to lie in the destinationroot
  # and has a name that starts with variable backupDirFlag
  def backupdirectory?(dir)
    inDestinationRootDir?(dir) && FiRe::filesys.basename(dir).match(/^#{@backupDirFlag} /)
  end
  
end
