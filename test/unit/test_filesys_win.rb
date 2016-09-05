require_relative '../../lib/helpers/filesys_win'
require_relative 'unit_test'
require 'minitest/autorun'

class TestFilesysWin < UnitTest

	def test_root_directory_on_windows
	  target = FilesysWin.new
	  assert "H:/" == target.dirname("H:")
	  assert "H:/" == target.dirname("H:\\")
	end

end  
