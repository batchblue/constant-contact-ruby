require 'helper'

class TestConstantContactRuby < Test::Unit::TestCase
  def test_setup
    ConstantContact.setup( 'u', 'p' )
    assert_equal 'https://api.constantcontact.com/ws/customers/u', ConstantContact.base_uri
  end
end
