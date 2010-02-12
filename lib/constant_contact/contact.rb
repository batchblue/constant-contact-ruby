module ConstantContact
  class Contact

    attr_reader :uid

    def initialize( params={} )
      return false if params.empty?

      @uid = params['id'].split('/').last

      params['content']['Contact'].each do |k,v|
        instance_eval %{
          @#{k.downcase} = "#{v}"

          def #{k.downcase}
            @#{k.downcase}
          end
        }
      end

    end

    class << self
      
      # list all contacts
      def all( options={} )
        contacts = []

        data = ConstantContact.get( '/contacts', options )
        return contacts if ( data.nil? or data.empty? )

        data['feed']['entry'].each do |entry|
          contacts << new( entry )
        end

        contacts
      end
      
      # add a new contact
      def add( data )
      end
      
      # get single contact by id
      def get( id, options={} )
        data = ConstantContact.get( "/contact/#{id.to_s}", options )
        'foo'
      end
      
      # update a single contact record
      def update( id, data )
      end
      
      # search for a contact by email address or last updated date
      def search( options={} )
      end

    end

  end
end
