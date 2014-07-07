module Patches
  module VersionsControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        helper :repositories
        
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      
    end
  end
end

VersionsController.send(:include, Patches::VersionsControllerPatch)