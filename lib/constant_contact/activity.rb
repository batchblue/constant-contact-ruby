module ConstantContact 
  class Activity < BaseResource

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
      new( activity['entry'], data.body )
    end

    # Add multiple users to one or more contact lists
    def self.add_users_to_lists( users=[], *lists )

    end

    # Remove multiple users from a contact list
    def self.remove_users_from_list( users=[], list_id=nil )
      return if list_id.nil?
    end

    # Remove all users from a specific contact list
    def self.remove_all_users_from_list( list_id )

    end

    # Export subscribers list to a file
    def self.export( list_id )

    end

  end # class Activity
end # module ConstantContact
