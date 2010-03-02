module ConstantContact
  class BaseResource #:nodoc:
    
    private 

    def self.camelize( string )
      string.split( /[^a-z0-9]/i ).map{ |w| w.capitalize }.join
    end

    def camelize( string )
      BaseResource.camelize( string )
    end

    def self.underscore( string )
      string.to_s.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
    end
    
    def underscore( string )
      BaseResource.underscore( string )
    end
    
  end
end
