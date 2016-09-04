require 'lib/workers/rolling_backup'
require 'lib/helpers/resource_locator'
require 'test/fakes/filesys_with_counters'
require 'test/unit'
require 'test/full/utils'


# The Rolling-Backup worker moves given destination to a backup-
# folder below the root of backup-folder. The paramerer "history"
# states how many backups will be kept before overwriting the oldest.
# Please note that this worker does not copy anything, only moves backup-dir
# to an archive-folder. The archive is named "rolling backup yyyy-mm-dd HHMMSS".
class TestRollingBackup < Test::Unit::TestCase
  
  def setup
    
    ResourceLocator.init
    Utils.setupDirs   
     
    # setup config for our run
    @backupDirFlag = "rolling backup" 
    @history = 2
    @destination = "test/data/dest"
    @rollingBackup = {
      "worker" => "ROLLING_BACKUP",
      "parameters" => {
        "history" => @history, 
        "destination" => @destination
      }
    }
    @cfg = { "jobs" => [ @rollingBackup ] }
   
  end
  
  def setupWithOneFile
    destfile = Utils.fullDestName(@cfg, "sub/newfile.txt")
    Utils.setupFile(destfile)
  end
  
  def test_shouldExecuteWithoutFailure
    Utils.runFiRe(@cfg)
  end
  
  def test_shouldNotKeepAnyStuffInDestDirExceptBackupDirs
    setupWithOneFile
    Utils.runFiRe(@cfg)
    Find.find(@destination) { |item| assertBackupDirMatch(item) }
  end
  
  def test_shouldMoveDestStructureToRollingBackup
  
    setupWithOneFile
    destfile = Utils.fullDestName(@cfg, "#{@backupDirFlag} 2008-07-13 213412/file.txt")
    Utils.setupFile(destfile)

    Utils.runFiRe(@cfg)

    Find.find(@destination) { |item| assertBackupDirMatch(item) }

  end
  
  def test_shouldCreateNewRollingBackup
    
    setupWithOneFile
    destfile = Utils.fullDestName(@cfg, "#{@backupDirFlag} 2008-07-13 213412/file.txt")
    Utils.setupFile(destfile)

    Utils.runFiRe(@cfg)
    
    found = false
    Find.find(@destination) { |item| found = item > "#{@backupDirFlag} 2008-07-13" }
      
    assert(found, "did not find new rolling backup dir")

  end
  
  def test_shouldReplaceOldestRollingBackup
    
    # setup with full set of backups
    setupWithOneFile
    backupnames = [
      "#{@backupDirFlag} 2008-07-13 213410",
      "#{@backupDirFlag} 2008-07-13 213411" ]
    Utils.setupFile(Utils.fullDestName(@cfg, "#{backupnames[0]}/file.txt"))
    Utils.setupFile(Utils.fullDestName(@cfg, "#{backupnames[1]}/file.txt"))

    # run
    Utils.runFiRe(@cfg)

    # verify
    count = 0
    Find.find(@destination) { |item|
      assertBackupDirMatch(item)
      assert( !item.match(backupnames[0]), "did not replace oldest backup")
      count += 1 if FiRe::filesys.dirname(item)==@destination
    }
    assert_equal(@history, count, "strange no. of backupdirs")
    
  end

    
  def test_shouldOnlyCountTopmostRollingBackup
    
    # use fake filesystem that counts filesystem-calls
    ResourceLocator.setFilesystem(FilesysWithCounters.new)
    
    # setup with full set of backups
    setupWithOneFile
    backupnames = [
      "#{@backupDirFlag} 2008-07-13 213420",
      "#{@backupDirFlag} 2008-07-13 213421" ]
    Utils.setupFile(Utils.fullDestName(@cfg, "#{backupnames[0]}/#{backupnames[1]}/file.txt"))

    # run
    RollingBackup.new(@cfg["jobs"][0]["parameters"]).execute

    # verify
    assert_equal(0, FiRe::filesys.count[:rm_rf], "did a removal when none should have been removed")
    
  end


  def assertBackupDirMatch(item)
    unless item == @destination
      # check that found item matches "/rolling backup "
      assert( item.match(/\/#{@backupDirFlag}\ [0-9\-]*/), "found item '#{item}' in destdir after rolling-backup") 
    end
  end

end

