require 'Find'
require 'fileutils'
require_relative 'path_wrapper'

# proxy to IO-operations
class FilesysProxy
  
  
  def find(path)
    catch (:prune) do
      Find.find(toUnix(path)) do 
        |f| yield(f)
      end
    end
  end

  def prune()
    throw(:prune)
  end

  def file?(o)
    File.file?(toUnix(o))
  end


  def directory?(o)
    File.directory?(toUnix(o))
  end


  def uptodate?(file, srcfile)
    file = toUnix(file)
    srcfile = toUnix(srcfile)
    
    if !File.exist?(srcfile)
      raise ArgumentError, "The sourcefile #{srcfile} with does not exist."
    elsif File.exist?(file)
      File.stat(file).mtime >= File.stat(srcfile).mtime
    else
      false
    end
      
  end
  
  
  def exist?(item)
    File.exist?(toUnix(item)) 
  end


  def size?(file)
    File.stat(toUnix(file)).size?
  end
  
  def mkpath(dir)
    FileUtils.mkpath(toUnix(dir))
  end
  
  
  def basename(path)
    File.basename(toUnix(path))
  end
  
  
  def dirname(path)
    File.dirname(toUnix(path))
  end
  
  
  def cp(src,dest)
    FileUtils.cp(toUnix(src), toUnix(dest), :preserve => true)
  end
  
  
  def mv(src,dest)
    FileUtils.mv(toUnix(src),toUnix(dest))
  end
  
  
  def rm_rf(src)
    FileUtils.rm_rf(toUnix(src), :verbose => true)
  end
  
  
  def expand_path(item)
    File.expand_path(toUnix(item))
  end


  def join(item,*items)
    File.join(toUnix(item), items.collect! {|i| toUnix(i)})
  end

private
  # wraps creation of pathwrapper
  def toUnix(path)
    PathWrapper.new(path)
  end
end