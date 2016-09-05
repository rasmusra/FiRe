require_relative '../helpers/resource_locator'
require_relative '../extensions/string'
require 'yaml'
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
    fn = workerConfig["worker"].downcase
    cls = fn.camelize!
    
    FiRe::log.info "--------------------------------- creating #{cls}"
    FiRe::log.info "config: #{workerConfig.to_yaml}"
    
    # require the library for the job
    require_relative fn
    
    # create the class for the job 
    klass = Object.const_get(cls)
    
    # return an instance of the worker 
    klass.new(workerConfig["parameters"])
    
  end
  
end