require_relative "../../lib/helpers/path_wrapper"
require_relative 'unit_test'
require 'minitest/autorun'

class TestPathWrapper < UnitTest

	def test_raiseErrorOnUncAddress
  
		begin			
			PathWrapper.new("\\\\some\\unc\\address")
		rescue StandardError => e
			ex = e
		end
		
		assert ex != nil
	end
end
