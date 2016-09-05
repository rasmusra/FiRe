require_relative '../../lib/extensions/string'
require_relative 'unit_test'
require 'minitest/autorun'

class TestString < UnitTest

	def test_camelize_snake_case
		assert_equal("HelloWorld", "hello_world".camelize!)
	end
end
