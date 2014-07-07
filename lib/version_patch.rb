#!/bin/env ruby
# encoding: utf-8

module Patches
  module VersionPatch
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
      # Get revisions list for version
      def get_revisions
        revs = []
        fixed_issues.each do |issue| 
          revs += issue.changesets
        end
        revs.uniq
      end

      # Получение полей Объекты в БД по списку задач в версии
      def get_dbobjects
        dbobjects = Hash.new{|hash,key| hash[key] = Set.new}
        fixed_issues.each do |issue| 
          issue.get_dbobjects.each do |el|
            dbobjects[el].add(issue)
          end
        end
        dbobjects
      end
      
      # Получение полей Данные в БД по списку задач в версии
      def get_dbdata
        dbdata = Hash.new{|hash,key| hash[key] = Set.new}
        fixed_issues.each do |issue| 
          issue.get_dbdata.each do |el|
            dbdata[el].add(issue)
          end
        end
        dbdata
      end
      
      # Получение шаблонов отчетов измененных в задаче
      def get_report_templates
        report_templates = []
        fixed_issues.each do |issue| 
          issue.changesets.each do |revision|
            revision.filechanges.each do |change|
              report_templates += [change.path] if (change.path.index(Setting.plugin_redmine_build_version['report_template_substring']))
            end
          end
        end
        report_templates.compact.uniq.sort_by { |x| x.downcase }
      end
      
    end
  end
end

Version.send(:include, Patches::VersionPatch)