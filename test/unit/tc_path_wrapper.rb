require "lib/helpers/path_wrapper"
require 'test/unit'

class TestPathWrapper < Test::Unit::TestCase

	def test_raiseErrorOnUncAddress
  
		begin			
			PathWrapper.new("\\\\some\\unc\\address")
		rescue StandardError => e
			ex = e
		end
		
		assert ex != nil
	end
end
