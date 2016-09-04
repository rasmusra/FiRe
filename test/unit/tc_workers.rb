require "lib/workers/replace_old_or_smaller_files"
require "test/fakes/fake_file_system"
require "test/unit"


class TestWorkers < Test::Unit::TestCase
  
  def setup
    
    # do not touch the filesystem, uh...
    ResourceLocator.setFilesystem(FakeFileSystem.new)
    
    # some shortcuts for tests, we only care about first job
    @source = "test/data/src"
    @destination = "test/data/dest"
    @workerReplaceOldOrSmallerFilesData = 
      {
        "name" => "REPLACE_OLD_OR_SMALLER_FILES", 
        "source" => @source, 
        "destination" => @destination 
      }
    @target = ReplaceOldOrSmallerFiles.new(@workerReplaceOldOrSmallerFilesData)
    
  end
  
  
  def test_shouldNotCopyExistingItem
    
    # setup with one file already in destdir
    setupSrcStructure
    existingItem = "subdir1/file4.txt"
    FiRe::filesys.addSrc("#{@source}/#{existingItem}") 
    FiRe::filesys.addDest("#{@destination}/#{existingItem}")
    
    # run
    @target.execute
   
    # verify by checking what has been copied, should not fail
    FiRe::filesys.copiedStructure.each { |copiedItem| 
      assert(!copiedItem.match(existingItem))
    }
    
  end
  
  
  def test_shouldNotTryToRemoveTrashfolder
    
    # setup with trashdir in dest
    trashDir = "#{@destination}/trashed"
    FiRe::filesys.addDest(trashDir) 
    
    # run
    @target.execute
    
    # verify by checking what has been removed
    assert_equal(0, FiRe::filesys.removedFiles.size, "hey! what was removed here?")
    
  end
  
  
  def test_shouldCopySrcFilesToDestDirAlsoWhenExistingHavingSmallerSize
    
    # setup with one file already in destdir
    setupSrcStructure
    FiRe::filesys.addSrc("#{@source}/subdir1/file5.txt") 
    FiRe::filesys.addDestWithSmallSize("#{@destination}/subdir1/file5.txt") 
    
    # run
    @target.execute
    
    # verify by checking what has been copied, should not fail
    FiRe::filesys.srcDirStructure.each { |srcItem|
      destItem = srcItem.sub(@source,@destination)
      assert(FiRe::filesys.copiedStructure.include?(destItem), "missing srcitem in dest-structure")
    }
    
  end

  
  def setupSrcStructure
    FiRe::filesys.addSrc("#{@source}/file1.txt") 
    FiRe::filesys.addSrc("#{@source}/subdir1") 
    FiRe::filesys.addSrc("#{@source}/subdir1/file2.txt") 
    FiRe::filesys.addSrc("#{@source}/subdir1/file3.txt") 
    FiRe::filesys.addSrc("#{@source}/subdir1/subdir2") 
    FiRe::filesys.addSrc("#{@source}/subdir1/subdir2/file4.txt") 
    FiRe::filesys.addSrc("#{@source}/subdir1/subdir3") 
  end
  
end

