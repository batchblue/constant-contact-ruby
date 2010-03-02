module ConstantContact 
  class Activity < BaseResource

    ADD_CONTACTS        = 'ADD_CONTACTS'.freeze
    REMOVE_CONTACTS     = 'REMOVE_CONTACTS_FROM_LISTS'.freeze
    CLEAR_CONTACTS      = 'CLEAR_CONTACTS_FROM_LISTS'.freeze
    EXPORT_CONTACTS     = 'EXPORT_CONTACTS'.freeze

    attr_reader :uid, :original_xml

    def initialize( params={}, orig_xml='' ) #:nodoc:
      return false if params.empty?

      @uid = params['id'].split('/').last
      @original_xml = orig_xml

      fields = params['content']['Activity']
      
      if errors = fields.delete( 'Errors' )
        # FIXME: handle the <Errors> node properly
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

    end

    # List all activities
    def self.all( options={} )
      activities = []

      data = ConstantContact.get( '/activities', options )
      return activities if ( data.nil? or data.empty? or data['feed']['entry'].nil? )

      data['feed']['entry'].each do |entry|
        activities << new( entry )
      end

      activities
    end

    # Get the details of a specific activity
    def self.get( id, options={} )
      activity = ConstantContact.get( "/activities/#{id.to_s}", options )
      return nil if ( activity.nil? or activity.empty? )
      new( activity['entry'], activity.body )
    end

    # Add multiple users to one or more contact lists
    def self.add_contacts_to_lists( users=[], *lists )
      data_param = build_data_param( users )
      list_param = lists.map { |list| ContactList.url_for( list.to_s ) }

      data = ConstantContact.post( '/activities', 
                                  :headers => { 'Content-Type' => 'application/x-www-form-urlencoded' }, 
                                  :body => { :activity => ADD_CONTACTS, :data => data_param, :lists => list_param } )

      if data.code == 201
        new( data['feed']['entry'] )
      else
        puts "HTTP Status Code: #{data.code}, message: #{data.message}"
        return false
      end
    end

    # Remove multiple users from a contact list
    def self.remove_contacts_from_lists( users=[], *lists )
      data_param = build_data_param( users )
      list_param = lists.map { |list| ContactList.url_for( list.to_s ) }

      data = ConstantContact.post( '/activities', 
                                  :headers => { 'Content-Type' => 'application/x-www-form-urlencoded' }, 
                                  :body => { :activity => REMOVE_CONTACTS, :data => data_param, :lists => list_param } )

      if data.code == 201
        new( data['feed']['entry'] )
      else
        puts "HTTP Status Code: #{data.code}, message: #{data.message}"
        return false
      end
    end

    # Remove all users from a specific contact list
    def self.remove_all_contacts_from_lists( *lists )
      # list_param = lists.map { |list| ContactList.url_for( list.to_s ) }
      
      # FIXME: this is hack because passing in an array of lists wasnt working because of Hash.to_params
      #         Hash#to_params returns lists[]=foo&lists[]=bar instead of lists=foo&lists=bar
      #         I can't even find where Hash#to_params is defined!!!
      list_param = ''
      lists.each do |list|
        list_param << "#{ContactList.url_for( list.to_s )}&lists="
      end

      data = ConstantContact.post( '/activities', 
                                  :headers => { 'Content-Type' => 'application/x-www-form-urlencoded' }, 
                                  :body => { 'activityType' => CLEAR_CONTACTS, :lists => list_param.chomp('&lists=') } )

      if data.code == 201
        new( data['feed']['entry'] )
      else
        puts "HTTP Status Code: #{data.code}, message: #{data.message}"
        return false
      end
    end

    # Export subscribers list to a file
    def self.export( list_id )

    end

    private

    # Build the data= query param for a POST request
    #
    # @param [Array] Users - an array of user hash objects
    #
    def self.build_data_param( users )
      return '' if users.empty? 
      data_start, data_end = '', ''
      keys, fields = [], []

      # get a list of all the key fields and then create values
      users.each do |u| 
        u.each_key do |k| 
          readable_key = underscore(k).split('_').map{|x| x.capitalize}.join(' ')
          packet = { :original => k, :readable => readable_key }
          keys << packet unless keys.include?( packet )
        end 
      end
      data_start = keys.map { |k| k[:readable] }.join(',') + "\n"

      # now build the data fields
      users.each do |u|
        tmp = ''
        keys.each { |k| tmp << "#{u[k[:original]]}," }
        fields << tmp.chomp(',') + "\n"
      end
      data_end = fields.join

      return data_start + data_end
    end

  end # class Activity
end # module ConstantContact
