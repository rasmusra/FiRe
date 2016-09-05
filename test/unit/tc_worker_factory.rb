require 'test/unit'
require_relative "../../lib/helpers/resource_locator"
require_relative "../../lib/workers/worker_factory"

class TestWorkerFactory < Test::Unit::TestCase



  def findWorkers
    workers = []
    
    Find.find("lib/workers") { |i|
    
      # do not generate any if not a ruby-classfile
      next if !i.match(/\.rb$/) || i.match(/general_worker.rb$/) || i.match(/worker_factory.rb$/) 
      
      # transform the filenames, like foo_bar.rb, to worker-names, like FOO_BAR
      filename = File.basename(i)
      libname = filename.sub(/\.rb/,"")
      workers.push(libname.upcase)
          
    }
    workers
  end
  
  def test_respondsToExecute
    
    # get all worker-classes 
    workers = findWorkers
    
    # create them, should not fail
    workers.collect! { |w| WorkerFactory.create({"worker"=>w, "parameters"=>{ "source"=>"","destination"=>""}}) }
 
    # check they implement execute
    workers.each { |w| 
      assert(w.respond_to?("execute"), "Worker #{w} does not respond to execute") 
    }
  end

end