  
class FilesysWithCounters < FilesysProxy
attr_reader :count
  
  def initialize
    super
    @count = {:cp=>0,:rm_rf=>0}
  end
  
  def cp(src,dest)
    super(src,dest)
    @count[:cp] += 1
  end
  
    
  
  def rm_rf(src)
    super(src)
    @count[:rm_rf] += 1
  end

end
