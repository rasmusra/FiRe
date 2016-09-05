require_relative "../../lib/helpers/filesys_win"
require 'test/unit'

class TestFilesysWin < Test::Unit::TestCase

	def test_root_directory_on_windows
	  target = FilesysWin.new
	  assert "H:/" == target.dirname("H:")
	  assert "H:/" == target.dirname("H:\\")
	end

end  
