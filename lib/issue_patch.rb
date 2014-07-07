#!/bin/env ruby
# encoding: utf-8

module Patches
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      # Get DB objects changed in the issue
      def get_dbobjects
        cv = custom_field_values.detect{|c| c.custom_field.name == Setting.plugin_redmine_build_version['dbobjects_field_name'] && c.value }
        cv = cv ? cv.value.delete("\r").gsub(",\n", "\n").tr(',', "\n").split("\n").map(&:strip) : []
        cv.reject{|e| e == "" }
      end

      # Get DB data changed in the issue
      def get_dbdata
        cv = custom_field_values.detect{|c| c.custom_field.name == Setting.plugin_redmine_build_version['dbdata_field_name'] && c.value }
        cv = cv ? cv.value.delete("\r").gsub(",\n", "\n").tr(',', "\n").split("\n").map(&:strip) : []
        cv.reject{|e| e == "" }
      end
      
      # Get report templates commited in the issue
      def get_report_templates
        report_templates = []
        changesets.each do |revision|
          revision.filechanges.each do |change|
            report_templates += [change.path] if (change.path.index(Setting.plugin_redmine_build_version['report_template_substring']))
          end
        end
        report_templates.compact.uniq.sort_by { |x| x.downcase }
      end 
      
    end
  end
end

Issue.send(:include, Patches::IssuePatch)