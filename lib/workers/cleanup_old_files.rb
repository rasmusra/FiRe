require 'lib/helpers/path_wrapper'
require 'lib/helpers/resource_locator'
include FiRe



# Use this worker to remove files from desitnation directories
# that are not anymore in source directory and that you want to
# remove from destionations. The cleaned items are moved to
# a trash-folder
class CleanupOldFiles
  
  def initialize(workerConfig)
    @source = PathWrapper.new(workerConfig["source"])
    @destination = PathWrapper.new(workerConfig["destination"])
  end

  
  # removes all files from destdir that is not found in srcdir
  def execute

    # build path to trashfolder
    trashfolder = FiRe::filesys.join(@destination,"trashed")
  
    # count trashed items for giving feedback afterwards
    counter = 0
    
    # traverse all destfiles
    FiRe::filesys.find(@destination) do |destItem|
            
      # give some feedback
      FiRe::log.info "searching #{destItem}..." if FiRe::filesys.directory?(destItem)

      # filter out trashfolder, that one we want to keep
      FiRe::filesys.prune if destItem.match(trashfolder)

      # transform destpath to srcpath 
      srcItem = destItem.gsub(@destination, @source)

      # remove it if not found in srcdir
      if !FiRe::filesys.exist?(srcItem)
        remove(destItem, trashfolder) 
        counter = counter + 1
      end

    end
            
    # give some feedback
    FiRe::log.info "trashed #{counter} items!"

  end


private

  def remove(destItem, trashfolder)

    # change path to trashfolder
    trashedItem = destItem.sub(@destination,trashfolder)
        
    # create the path to trashed item
    FiRe::filesys.mkpath(File.dirname(trashedItem)) 

    # move the item from destfolder to trashed items
    FiRe::log.info "trashing #{destItem}"
    FiRe::filesys.mv(destItem,trashedItem) 
    
  end
end
