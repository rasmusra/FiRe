require 'lib/helpers/filesys_proxy'

# handles the windows-platforms way of separating dirs in paths
class FilesysWin < FilesysProxy
  
  def dirname(path)
  
    # reuse baseclass' dirname-func 
    result = super(path)
    
    # ...but remove any trailing dots, match pattern /., \. and :.
    # these dots occurs when giving win-dirs like H: that else becomes H:.
    result.gsub!(/.$/,"") if result.match(/[\/\\\:]\.$/)
    
    result

  end
  
end

