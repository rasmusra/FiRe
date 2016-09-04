require 'FileUtils'

class Utils
 
  
  def Utils.runFiRe(cfg)
    
    # just put the tmp configfile somewhere
    configfile = "test/data/tmp.yml"
    
    # create the configfile
    f = File.open(configfile, "w")
    f.print(cfg.to_yaml)
    f.close

    # add args if not done before
    if !$*.include?("-config")
      $*.push("-config") 
      $*.push(configfile)
    end
    
    # run program
    require 'lib/fire.rb'
    main
    
  end
  
  # extracts some reusable code, assumes there's only one worker in config
  def Utils.fullSrcName(cfg, subpath, convertForMSWin = true)
    srcfile = File.expand_path("#{cfg["jobs"][0]["parameters"]["source"]}/#{subpath}")    
    srcfile.gsub!(/\//,"\\") if RUBY_PLATFORM =~ /mswin/ && convertForMSWin
    srcfile
  end
  
  # extracts some reusable code, assumes there's only one worker in config
  def Utils.fullDestName(cfg, subpath, convertForMSWin = true)
    destfile = File.expand_path("#{cfg["jobs"][0]["parameters"]["destination"]}/#{subpath}")
    destfile.gsub!(/\//,"\\") if RUBY_PLATFORM =~ /mswin/ && convertForMSWin
    destfile
  end
  
  # extracts some reusable code, assumes there's only one worker in config
  def Utils.src2dest(cfg,srcItem)
    src = cfg["jobs"][0]["parameters"]["source"]
    dest = cfg["jobs"][0]["parameters"]["destination"]
    srcItem.sub(src, dest)
  end

  # extracts some reusable code
  def Utils.setupDirs
 
    # remove the logs-directory so that we know it will work without one initially
    FileUtils.rm_rf("logs", :verbose => true)
    
    # remove any old stuff and setup new clean structure
    FileUtils.rm_rf("test/data", :verbose => true)
    FileUtils.mkpath("test/data/src/sub", :verbose => true)
    FileUtils.mkpath("test/data/dest", :verbose => true)
 
  end
   
  # extracts some reusable code
  def Utils.setupFile(fullpath)
    FileUtils.mkpath(File.dirname(fullpath))
    FileUtils.cp( $0, fullpath, :preserve => true) 
  end

  def Utils.createConfig(worker, params)
    # use brute force for converting paths to windows
    if RUBY_PLATFORM =~ /mswin/
      params.merge!(params.each_value { |v| v.gsub!("/","\\") })
    end
  
    { "jobs" => 
      [ {
        "worker" => worker,
        "parameters" => params
      } ] 
    }
  end

end
