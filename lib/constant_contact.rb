module ConstantContact#:nodoc:

    include HTTParty
    format :xml
    headers 'Accept'        => 'application/atom+xml'
    headers 'Content-Type'  => 'application/atom+xml'
    
    API_KEY = "59ca4bb4-51e9-4c08-a2b2-a34aac7bb78f"

    class << self
      def setup( user, pass )
        basic_auth "#{API_KEY}%#{user}", pass
        base_uri "https://api.constantcontact.com/ws/customers/#{user.downcase}"
      end
    end

end
