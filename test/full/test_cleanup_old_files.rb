require_relative 'utils'
require_relative 'full_test'
require 'minitest/autorun'
require 'FileUtils'

class TestCleanupOldFiles < FullTest
  
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
  
  def test_execute
    Utils.runFiRe(@cfg)
  end
  
  
  def test_moving_old_file_to_trash_folder

    # setup destdir with a small textfile that's not existing in srcdir
    oldfile = File.expand_path("#{@destination}/sub/oldfile.txt")
    expectedTrashedFile = File.expand_path("test/data/dest/trashed/sub/oldfile.txt")
    Utils.setupFile(oldfile)
    
    # run
    Utils.runFiRe(@cfg)
    
    # verify
    assert(!File.exist?(oldfile), "file #{oldfile} was not removed")
    assert(File.exist?(expectedTrashedFile), "file #{expectedTrashedFile} was not trashed")
  end

end

