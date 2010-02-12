module ConstantContact
  class Contact

    attr_reader :name, :email_address, :email_type, :status, :id

    def initialize( params={} )
      return false if params.empty?

      info = params['content']['Contact']

      @id             = params['id'].split('/').last
      @name           = info['Name']
      @email_address  = info['EmailAddress']
      @email_type     = info['EmailType']
      @status         = info['Status']
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
      def add
      end
      
      # get single contact by id
      def get
      end
      
      # update a single contact record
      def update
      end
      
      # search for a contact by email address or last updated date
      def search( options={} )
      end

    end

  end
end
