require 'rubygems'
require 'optiflag'
require_relative 'helpers/filesys_proxy'
require_relative 'helpers/resource_locator'
require_relative 'workers/worker_factory'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
include Log4r
include FiRe


# setup log4r
cfg = YamlConfigurator 
cfg['HOME'] = '.'
FileUtils.mkpath 'logs'
cfg.load_yaml_file('config/log4r.yml')



# this module uses OptiFlag-lib for parsing cmdline-args
module ArgParser extend OptiFlagSet  
  
  flag "config" do
    alternate_forms "cfg", "c"
    description "The path to the yaml-config file"
  end
  
  and_process!
end



def main
  begin  
  
    ResourceLocator.setLog(Logger["log"])
    FiRe::log.info "Starting up!"
    configdata = YAML.load(File.open(ARGV.flags.config.to_s)) 
    
    configdata["jobs"].each { |w| 
      WorkerFactory.create(w).execute
    }
  
  rescue StandardError => e
    log.fatal e
    raise
  end
end


if __FILE__ == $0
  main
end
