module ConstantContact 
  class ContactList < BaseResource

    attr_reader :uid, :original_xml

    def initialize( params={}, orig_xml='' ) #:nodoc:
      return false if params.empty?

      @uid = params['id'].split('/').last
      @original_xml = orig_xml

      params['content']['ContactList'].each do |k,v|
        underscore_key = underscore( k )

        instance_eval %{
          @#{underscore_key} = "#{v}"

          def #{underscore_key}
            @#{underscore_key}
          end
        }
      end
    end

    # Update a contacts attributes
    def update_attributes!( params={} )
      return false unless full_record?

      params.each do |key,val|
        self.instance_variable_set("@#{key.to_s}", val)
      end

      data = ConstantContact.put( "/lists/#{self.uid}", :body => self.send(:to_xml) )

      if data.code == 204
        return true
      else
        return data # probably should raise an error here instead
      end
    end

    # Remove all contacts from the contact list
    def clear_contacts!
      Activity.remove_all_contacts_from_lists( self.uid )
    end

    # Get all contact lists
    def self.all( options={} )
      lists = []

      data = ConstantContact.get( '/lists', options )
      return lists if ( data.nil? or data.empty? )

      data['feed']['entry'].each do |entry|
        lists << new( entry )
      end

      lists
    end

    # Add a new contact list
    def self.add( name, opt_in=false, sort_order=99, options={} )
      return nil if( name.nil? || name.empty? )

      xml = build_contact_list_xml_packet( name, opt_in, sort_order )

      options.merge!({ :body => xml })
      data = ConstantContact.post( "/lists", options )

      if data.code == 201
        return new( data['entry'] )
      else
        puts "HTTP Status Code: #{data.code}, message: #{data.message}"
        return nil
      end
    end

    # Delete a contact list
    def self.delete( id, options={} )
      data = ConstantContact.delete( "/lists/#{id.to_s}", options )
      return ( data.code == 204 ) ? true : false
    end

    # Get a single contact list
    def self.get( id, options={} )
      list = ConstantContact.get( "/lists/#{id.to_s}", options )
      return nil if ( list.nil? or list.empty? )
      new( list['entry'], list.body )
    end

    # Get a lists members
    def self.members( id, options={} )
      fetch_members(id, options)
    end

    # Returns the objects API URI
    def self.url_for( id )
      "#{ConstantContact.base_uri}/lists/#{id}"
    end

    private

    def self.build_contact_list_xml_packet( name, opt_in=false, sort=99 )
      xml = <<EOF
<entry xmlns="http://www.w3.org/2005/Atom">
  <updated>#{Time.now.strftime("%Y-%m-%dT%H:%M:%S.000Z")}</updated>
  <title  />
  <author />
  <id>data:,none</id>
  <content type="application/vnd.ctct+xml">
    <ContactList xmlns="http://ws.constantcontact.com/ns/1.0/">
      <Name>#{name}</Name>
      <SortOrder>#{sort}</SortOrder>
      <OptInDefault>#{opt_in.to_s}</OptInDefault>
    </ContactList>
  </content>
</entry>
EOF
      xml
    end
    
    def self.fetch_members( id, options={} )
      contacts = []
      link     = "/lists/#{id.to_s}/members"
      if options['next_link']
        full_link = options.delete('next_link')
        link += "?#{full_link.split('?').last}"
      end
      
      members = ConstantContact.get( link, options )
      return nil if ( members.nil? or members.empty? )
      
      if( members['feed']['entry'].is_a?(Array) )
        contacts = members['feed']['entry'].collect { |entry| Contact.new( entry, '', true ) }
      else
        contacts = [Contact.new( members['feed']['entry'], '', true )]
      end
      
      if feed_has_next_link?(members['feed'])
        next_link = find_next_link members['feed']
        contacts += fetch_members(id, options.merge!('next_link' => next_link))
      end
      
      contacts
    end

    def self.feed_has_next_link?(feed)
      !find_next_link(feed).nil?
    end

    def self.find_next_link(feed)
      feed['link'].collect { |link| link['href'] if link["rel"] && link["rel"] == 'next' }.compact.first
    end

    # Is this a full record or a summary record?
    def full_record?
      !self.members.emtpy?
    end

    # Convert the object into the needed API XML format
    def to_xml
      return nil unless full_record?

      do_not_process = [ "@original_xml", "@uid", "@members" ]

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

  end # class ContactList
end # module ConstantContact
