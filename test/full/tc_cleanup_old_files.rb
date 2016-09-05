require_relative 'utils'
require 'test/unit'


class TestCleanupOldFiles < Test::Unit::TestCase
  
  def setup

    # remove any old stuff and setup new clean structure
    Utils.setupDirs
     
    # setup config for our run
    @source = "test/data/src"
    @destination = "test/data/dest"
    params = {
      "source" => @source, 
      "destination" => @destination 
    }
    @cfg = Utils.createConfig("cleanup_old_files",params)
    
  end
  
  def test_shouldExecuteWithoutFailure
    Utils.runFiRe(@cfg)
  end
  
  
  def test_shouldMoveOldFileToTrashfolder
    
    # setup destdir with a small textfile that's not existing in srcdir
    oldfile = File.expand_path("#{@destination}/sub/oldfile.txt")
    expectedTrashedFile = File.expand_path("test/data/dest/trashed/sub/oldfile.txt")
    Utils.setupFile(oldfile)
    
    # run
    Utils.runFiRe(@cfg)
    
    # verify
    assert(!File.exist?(oldfile), "file #{oldfile} was not removed")
    assert(File.exist?(expectedTrashedFile), "file #{oldfile} was not removed")
    
  end


end

