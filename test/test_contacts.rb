require 'helper'
require 'contact'

class TestContact < Test::Unit::TestCase

  def setup
    ConstantContact.setup( 'user', 'password' )
  end

  def test_all_contacts
    contacts = ConstantContact::Contact.all
    assert !contacts.nil?
    assert_equal 2, contacts.size
    assert_equal ConstantContact::Contact, contacts.first.class

    assert_equal 'Customer 1', contacts.first.name
    assert_equal '21930', contacts.first.id
  end

  def test_all_contacts_with_bad_credentials
    FakeWeb.register_uri( :get, %r{https://.+:.+@api\.constantcontact\.com/ws/customers/.+/contacts}, :body => '', :status => ['403', 'Not Authorized'] )
    contacts = ConstantContact::Contact.all
    assert contacts.empty?
  end
end
