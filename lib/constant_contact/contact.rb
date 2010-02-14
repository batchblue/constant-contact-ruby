module ConstantContact
  class Contact < BaseResource

    attr_reader :uid

    def initialize( params={} )
      return false if params.empty?

      @uid = params['id'].split('/').last

      params['content']['Contact'].each do |k,v|
        underscore_key = underscore( k )
        instance_eval %{
          @#{underscore_key} = "#{v}"

          def #{underscore_key}
            @#{underscore_key}
          end
        }
      end

      # FIXME: properly handle the contactlists field if exists

    end

    class << self
      
      # Get a summary list all contacts
      def all( options={} )
        contacts = []

        data = ConstantContact.get( '/contacts', options )
        return contacts if ( data.nil? or data.empty? )

        data['feed']['entry'].each do |entry|
          contacts << new( entry )
        end

        contacts
      end
      
      # Add a new contact
      def add( data )
      end
      
      # Get detailed record for a single contact by id
      def get( id, options={} )
        data = ConstantContact.get( "/contact/#{id.to_s}", options )
        return nil if ( data.nil? or data.empty? )
        new( data['entry'] )
      end
      
      # Update a single contact record
      def update( id, data )
      end
      
      # Search for a contact by email address or last updated date
      def search( options={} )
      end

    end

  end
end
