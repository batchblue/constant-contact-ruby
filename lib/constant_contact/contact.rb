module ConstantContact
  class Contact < BaseResource

    attr_reader :uid, :contact_lists, :original_xml

    def initialize( params={}, orig_xml='', from_contact_list=false )
      return false if params.empty?
      
      @uid = params['id'].split('/').last
      @original_xml = orig_xml
      @contact_lists = []

      if from_contact_list
        fields = params['content']['ContactListMember']
      else
        fields = params['content']['Contact']
      end

      if lists = fields.delete( 'ContactLists' )
        if lists['ContactList'].is_a?( Array )
          @contact_lists = lists['ContactList'].collect { |list| list['id'].split('/').last }
        else
          @contact_lists << lists['ContactList']['id'].split('/').last
        end
      end

      fields.each do |k,v|
        underscore_key = underscore( k )
        
        instance_eval %{
          @#{underscore_key} = "#{v}"

          def #{underscore_key}
            @#{underscore_key}
          end
        }
      end

    end # def initialize

    # Update a single contact record
    #
    # NOTE: you cannot update a Contact's ContactList subscriptions through
    # this method.  Use the apropriate ContactList methods instead
    #
    def update_attributes!( params={} )
      return false unless full_record? # TODO: raise some kind of specific error here

      params.each do |key,val|
        self.instance_variable_set("@#{key.to_s}", val)
      end

      # self.send(:to_xml)
      data = ConstantContact.put( "/contacts/#{self.uid}", :body => self.send(:to_xml) )
      if data.code == 204 # success
        return true
      else
        return data # probably should raise an error here instead
      end
    end

    # Get a summary list all contacts
    def self.all( options={} )
      contacts = []

      data = ConstantContact.get( '/contacts', options )
      return contacts if ( data.nil? or data.empty? )

      data['feed']['entry'].each do |entry|
        contacts << new( entry )
      end

      contacts
    end
    
    # Add a new contact
    #
    # Required data fields:
    # * EmailAddress => String
    # * ContactLists => Array of list IDs
    #
    # Options data fields:
    # * EmailType
    # * FirstName
    # * MiddleName
    # * LastName
    # * JobTitle
    # * CompanyName
    # * HomePhone
    # * WorkPhone
    # * Addr1
    # * Addr2
    # * Addr3
    # * City
    # * StateCode => Must be valid US/Canada Code (http://ui.constantcontact.com/CCSubscriberAddFileFormat.jsp#states)
    # * StateName
    # * CountryCode = Must be valid code (http://constantcontact.custhelp.com/cgi-bin/constantcontact.cfg/php/enduser/std_adp.php?p_faqid=3614)
    # * CountryName
    # * PostalCode
    # * SubPostalCode
    # * Note
    # * CustomField[1-15]
    # * OptInSource
    # * OptOutSource
    # 
    def self.add( data={}, opt_in='ACTION_BY_CUSTOMER', options={} )
      xml = build_contact_xml_packet( data, opt_in )

      options.merge!({ :body => xml })
      data = ConstantContact.post( "/contacts", options )

      # check response.code
      if data.code == 201 # Entity Created
        return new( data['entry'] )
      else
        # data.code == 409 # Conflict ( probably a duplicate )
        puts "HTTP Status Code: #{data.code}, message: #{data.message}"
        return nil
      end
    end
    
    # Get detailed record for a single contact by id
    def self.get( id, options={} )
      data = ConstantContact.get( "/contacts/#{id.to_s}", options )
      return nil if ( data.nil? or data.empty? )
      new( data['entry'], data.body )
    end
    
    # Search for a contact by email address or last updated date
    # 
    # Valid options:
    # * :email => "Query String"
    # * :updated_since => Time object
    # * :list_type => One of 'active'|'removed'|'do-not-mail'
    #
    def self.search( options={} )
    end

    private

    def self.build_contact_xml_packet( data={}, opt_in='ACTION_BY_CUSTOMER' )
      xml = <<EOF
<entry xmlns="http://www.w3.org/2005/Atom">
  <title type="text"> </title>
  <updated>#{Time.now.strftime("%Y-%m-%dT%H:%M:%S.000Z")}</updated>
  <author></author>
  <id>data:,none</id>
  <summary type="text">Contact</summary>
  <content type="application/vnd.ctct+xml">
    <Contact xmlns="http://ws.constantcontact.com/ns/1.0/">
EOF
      
      data.each do |key, val|
        node = camelize(key.to_s)

        if key == :contact_lists
          xml << %Q(      <ContactLists>\n)
          val.each do |list_id|
            xml<< %Q(       <ContactList id="#{ContactList.url_for( list_id )}" />\n)
          end
          xml << %Q(      </ContactLists>\n)
        else
          xml << %Q(      <#{node}>#{val}</#{node}>\n)
        end
      end

      xml += <<EOF
      <OptInSource>#{opt_in}</OptInSource>
    </Contact>
  </content>
</entry>
EOF

      xml
    end # def build_contact_xml_packet

    # Is this a full contact record?
    def full_record?
      !self.contact_lists.empty?
    end

    # convert a full Contact record into XML format
    def to_xml
      return nil unless full_record?

      do_not_process =  [ "@contact_lists", "@original_source", "@original_xml", "@uid", "@xmlns" ]

      xml = self.original_xml

      self.instance_variables.each do |ivar|
        next if do_not_process.include?( ivar )

        var = camelize( ivar.gsub(/@/,'') )

        xml.gsub!( /<#{var}>(.*)<\/#{var}>/ , "<#{var}>#{self.instance_variable_get(ivar)}</#{var}>" )
      end

      # replace <updated> node with current time
      xml.gsub( /<updated>.*<\/updated>/, Time.now.strftime("%Y-%m-%dT%H:%M:%S.000Z") )

      xml
    end

  end # class Contact
end # module ConstantContact
