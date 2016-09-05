require 'minitest/autorun'
require_relative '../../lib/helpers/resource_locator'
require_relative '../../lib/workers/replace_old_or_smaller_files'
require_relative '../fakes/filesys_with_counters'
require_relative 'utils'
require_relative 'full_test'

class TestReplaceOldOrSmallerFiles < FullTest
  
  def setup
    
    # remove any old stuff and setup new clean structure
    Utils.setupDirs
     
    # setup config for our run
    @source = "test/data/src"
    @destination = "test/data/dest"
    @replaceOldOrSmaller = 
    {
      "worker" => "REPLACE_OLD_OR_SMALLER_FILES",
      "parameters" => 
      {
        "source" => @source, 
        "destination" => @destination 
      }
    }
    @cfg = { "jobs" => [ @replaceOldOrSmaller ] }
  end
  
  def test_execute
    Utils.runFiRe(@cfg)
  end
  
  
  def test_copy_new_file

    # setup srcdir with a file that's not existing in destdir
    srcfile = Utils.fullSrcName(@cfg, "sub/newfile.txt")
    Utils.setupFile(srcfile)
    expectedcopy = Utils.src2dest(@cfg, srcfile)
    
    # run
    Utils.runFiRe(@cfg)
    
    # verify
    assert(File.exist?(expectedcopy), "file #{expectedcopy} was not found")
    assert_equal(File.stat(srcfile).mtime, File.stat(expectedcopy).mtime, "The copy #{expectedcopy} got strange timestamp")
        
  end
  
  
  def test_copy_file_when_backup_exists_with_older_date

    # setup srcdir and destdir with samefile 
    srcfile = Utils.fullSrcName(@cfg, "sub/newfile.txt")
    backupfile = Utils.src2dest(@cfg, srcfile)
    Utils.setupFile(srcfile)
    Utils.setupFile(backupfile)
    
    # make the srcfile newer
    FileUtils.touch srcfile
    
    # run
    Utils.runFiRe(@cfg)
    
    # verify
    assert_equal(File.stat(srcfile).mtime, File.stat(backupfile).mtime, "file #{backupfile} was never replaced")
        
  end
  
  
  def test_copy_all
    setupBigSrcStructure(@cfg)
    Utils.runFiRe(@cfg)
    assert(allFilesFound?(), "all files was not found in destdir.")
  end
  
  
  def test_not_to_copy_file_when_same_modified_date
    
    # use fake filesystem that counts filesystem-calls
    ResourceLocator.setFilesystem(FilesysWithCounters.new)

    # setup srcfile
    srcfile = Utils.fullSrcName(@cfg, "sub/newfile.txt", false)
    Utils.setupFile(srcfile)
    
    # setup backupfile
    backupfile = Utils.src2dest(@cfg, srcfile)
    FileUtils.mkpath(File.dirname(backupfile))
    FileUtils.cp(File.expand_path(srcfile), File.expand_path(backupfile), :preserve => true)
    
    # run. cannot test from outermost function since we are mocking filesystem
    ReplaceOldOrSmallerFiles.new(@cfg["jobs"][0]["parameters"]).execute

    # verify
    assert_equal(0, FiRe::filesys.count[:cp], "files are exactly the same, but copy is still done")
      
  end
  
  
  def test_not_to_copy_files_in_ignore_list
    
    # use fake filesystem that counts filesystem-calls
    ResourceLocator.setFilesystem(FilesysWithCounters.new)

    # setup srcfiles
    Utils.setupFile(Utils.fullSrcName(@cfg, "sub/ignore.txt"))
    Utils.setupFile(Utils.fullSrcName(@cfg, "file.ign"))
    Utils.setupFile(Utils.fullSrcName(@cfg, "skippedDir/file.txt"))
    Utils.setupFile(Utils.fullSrcName(@cfg, "sub/file.txt"))
    
    # add to config what items should be ignored
    params = @cfg["jobs"][0]["parameters"]
    params["ignore"] = "*.ign,ignor*.*,skipped*"
    
    # run. cannot test from outermost function since we are mocking filesystem
    ReplaceOldOrSmallerFiles.new(params).execute

    # verify
    assert_equal(1, FiRe::filesys.count[:cp], "only one file is not ignored but that was not what was copied.")
      
  end

  
  def setupBigSrcStructure(cfg)
    Utils.setupFile(Utils.fullSrcName(cfg, "file1.txt"))
    Utils.setupFile(Utils.fullSrcName(cfg, "subdir1/file2.txt")) 
    Utils.setupFile(Utils.fullSrcName(cfg, "subdir1/file3.txt")) 
    Utils.setupFile(Utils.fullSrcName(cfg, "subdir1/subdir2/file4.txt")) 
    FileUtils.mkpath(Utils.fullSrcName(cfg, "subdir1/subdir3/"))
  end


  # searches destdir after all files in srcdir
  # returns false if any item is not found
  def allFilesFound?()
    d = File.expand_path(@source)
    Find.find(d) do |item|
      searcheditem = Utils.src2dest(@cfg, item)
      if !File.exist?(searcheditem)
        puts "allFilesFound?: did not find #{item} in destdir"
        return false 
      end
    end
    
    true
    
  end
  
  
end


