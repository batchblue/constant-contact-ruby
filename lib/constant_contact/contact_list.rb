module ConstantContact
  class ContactList < BaseResource

    attr_reader :uid

    def initialize( params={} )
      return false if params.empty?

      @uid = params['id'].split('/').last

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

    class << self

      # Get all contact lists
      def all( options={} )
        lists = []

        data = ConstantContact.get( '/lists', options )
        return lists if ( data.nil? or data.empty? )

        data['feed']['entry'].each do |entry|
          lists << new( entry )
        end

        lists
      end

      # Get a single contact list
      def get( id, options={} )
        list = ConstantContact.get( "/lists/#{id.to_s}", options )
        return nil if ( list.nil? or list.empty? )
        new( list['entry'] )
      end

      # Get a lists members
      def members( id, options={} )
        members = ConstantContact.get( "/lists/#{id.to_s}/members", options )
        return nil if ( members.nil? or members.empty? )
        members['feed']['entry'].collect { |entry| Contact.new( entry, true ) }
      end

    end

  end
end
