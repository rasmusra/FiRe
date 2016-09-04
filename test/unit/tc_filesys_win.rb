require 'lib/helpers/filesys_win'
require 'test/unit'

if RUBY_PLATFORM =~ /mswin/
  class TestFilesysWin < Test::Unit::TestCase
    
    def test_shouldGetCorrectDirname
      target = FilesysWin.new
      assert_equal("H:/",target.dirname("H:"))
      assert_equal("H:/",target.dirname("H:\\"))
    end
  end  
end
