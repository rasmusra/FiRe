class FakeFileSystem
  
  # these are attributes used for achieving sensing from testcode
  attr_reader :removedFiles
  attr_reader :copiedStructure
  attr_reader :srcDirStructure
  

  def initialize
    @srcDirStructure = []
    @existingFilesInDestStructure = []
    @halfFiles = []
    @copiedStructure = []
    @removedFiles = []
  end
  
  
  def file?(o)
    # "by convention", when adding files to srcstructure in testsetup
    # then be sure to name them like *.txt
    o.match(/.txt$/)
  end
  
  
  def directory?(o)
    !file?(o)
  end
  
  
  def uptodate?(file,srfile)
    @existingFilesInDestStructure.include?(file) 
  end
  
  
  def exist?(file)
    @existingFilesInDestStructure.include?(file) || @srcDirStructure.include?(file) 
  end
  
  
  def size?(file)
    
    if file.match(/zerosize/)
      nil

    elsif @halfFiles.include?(file)
      # the file exists in dest but is smaller!
      10
    
    elsif @srcDirStructure.include?(file) || @existingFilesInDestStructure.include?(file)
      # the file exists either in dest or in src 
      100
    
    else
      # does not exist
      0
    
    end
  end
  
  
  def find(path)
    catch (:prune) do
      if path.match("src")
        @srcDirStructure.each { |f| yield(f) }
      elsif path.match("dest")
        @existingFilesInDestStructure.each { |f| yield(f) }
      end
    end
  end


  def prune()
    throw(:prune)
  end

  
  def mkpath(dir)
    @copiedStructure.push(dir)
  end
  

  def cp(srcfile,destfile)
    @copiedStructure.push(destfile)
  end
  

  def cp_r(src,dest)
    @copiedStructure.merge(@dirStructure)
  end
  

  def mv(dest,src)
    @removedFiles.push(dest)
  end

  def join(item,*items)
    item + "/" + items.join("/")
  end
  
  def basename(file)
    "any text for test"
  end
  
  def expand_path(path)
    # just make it absolute
    "/".concat(path).sub(/^\/\//,"/")
  end


# here goes methods used for test-seams


  # this method is used by testclasses in setup-phase 
  def addSrc(item)
    @srcDirStructure.push(item)
  end


  # this method is used by testclasses in setup-phase,
  # usable when checking against existing dirs 
  def addDest(item)
    @existingFilesInDestStructure.push(item)
  end


  # this method is used by testclasses in setup-phase,
  # usable when checking against existing dirs 
  def addDestWithSmallSize(item)
    addDest(item)
    @halfFiles.push(item)
  end
 
  


end
