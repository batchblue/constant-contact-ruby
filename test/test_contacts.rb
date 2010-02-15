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
    assert_equal '21930', contacts.first.uid
  end

  def test_all_contacts_with_bad_credentials
    # FakeWeb.register_uri( :get, %r{https://.+:.+@api\.constantcontact\.com/ws/customers/.+/contacts}, :body => '', :status => ['403', 'Not Authorized'] )
    # contacts = ConstantContact::Contact.all
    # assert contacts.empty?
  end

  def test_get_contact
    contact = ConstantContact::Contact.get( 22199 )
    assert_equal 'Customer Joe', contact.name
    assert_equal '22199', contact.uid
    assert_equal 'joe@example.com', contact.emailaddress

    # TODO: contactLists
  end

  def test_add_contact
    # c = ConstantContact::Contact.add(
    #   :email_address => 'test@example.com',
    #   :first_name => 'First',
    #   :last_name => 'Name',
    #   :opt_in_source => 'ACTION_BY_CONTACT', # or ACTION_BY_CUSTOMER
    #   :contact_lists => [1]
    # )

    # assert_equal 'test@example.com', c.email_address
    # 
    # contact = ConstantContact::Contact.get( c.uid )
    # assert_equal 'test@example.com', contact.email_address
  end
end
