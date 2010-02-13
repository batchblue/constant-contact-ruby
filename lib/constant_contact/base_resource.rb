module ConstantContact
  class BaseResource
    
    private 
    
    def underscore( string )
      string.to_s.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
    end
    
  end
end