require 'lib/helpers/resource_locator'
include FiRe


# Factory-class for workers. The createJobs-method reads
# worker-list from config-file and returns list of worker-instances
# Naming conventions for workers in class and configfile are:
#
#   classname: FooBar
#   libname: 'lib/fire/workers/foo_bar.rb'
#   configname: foo_bar
#
# When the configname is found, the other two will 
# be read out of it.
class WorkerFactory
  

  # creates a worker for given worker-name. 
  def WorkerFactory.create(workerConfig)
    lib = WorkerFactory.libraryname(workerConfig["worker"])
    cls = WorkerFactory.classname(lib)
    
    FiRe::log.info "--------------------------------- creating #{cls}"
    FiRe::log.info "config: #{workerConfig.to_yaml}"
    
    # require the library for the job
    require lib
    
    # create the class for the job 
    klass = Object.const_get(cls)
    
    # return an instance of the worker 
    klass.new(workerConfig["parameters"])
    
  end

private

  # turns the given filename foo_bar into corresponding
  # classname FooBar
  def WorkerFactory.classname(lib)
    
    # extract last part in part
    idx = lib.rindex("/") + 1
    worker = lib[idx, lib.length-idx]
    
    # create camelcase-classname
    parts = worker.split("_").collect! { |p| p.capitalize! }
    parts.join
    
  end

  # turns the given string FOO_BAR into the corresponding
  # library-name, together with full lib-path. Workername cna be in any case. 
  # TODO: put hardcoded lib-path in config
  def WorkerFactory.libraryname(worker)
    return FiRe::filesys.join("lib","workers",worker.downcase)
  end
  
end