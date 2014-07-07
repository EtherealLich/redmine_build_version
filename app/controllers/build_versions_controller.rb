# Redmine - project management software
# Copyright (C) 2006-2014  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class BuildVersionsController < ApplicationController
    unloadable

    before_filter :find_model_object, :only => [:show]
    before_filter :find_project_from_association, :only => [:show]

    helper :custom_fields
    helper :projects
    helper :versions
    helper :repositories
    helper :build_versions
    include BuildVersionsHelper

    def find_model_object
        if (params[:id])
            @object = Version.find(params[:id])
            self.instance_variable_set('@version', @object) if @object
        end
    end 

    def index
        if request.post?
            if (params[:id] == 'revisions')
                @revs = params[:rev_list]
                @rev_list = @revs.split("\r\n").reject {|s| !s.match(/^r(\d*)$/) }.compact.uniq
                @revs = @rev_list.join("\r\n")
                @rev_list = @rev_list.select { |s| s[0] == 'r' }.map { |s| s[1..-1] }
                @issues = Issue.includes(:changesets).where(:changesets => {:revision => @rev_list}).sort.to_a
            elsif (params[:id] == 'issues')
                @issues_str = params[:issues_list]
                @issues_list = @issues_str.split(",").map(&:strip).compact.uniq
                @issues = Issue.includes(changesets: [:filechanges]).where(:id => @issues_list).sort.to_a
                
                @revisions = []
                @issues.each do |issue| 
                  @revisions += issue.changesets
                end
                @revisions = @revisions.uniq.sort
            end
            
            @dbobjects = Hash.new{|hash,key| hash[key] = Set.new}
            @dbdata = Hash.new{|hash,key| hash[key] = Set.new}
            @report_templates = []
            @issues.each do |issue| 
              issue.get_dbobjects.each do |el|
                @dbobjects[el].add(issue)
              end
              issue.get_dbdata.each do |el|
                @dbdata[el].add(issue)
              end
              issue.changesets.each do |revision|
                revision.filechanges.each do |change|
                  @report_templates += [change.path] if (change.path.index(Setting.plugin_redmine_build_version['report_template_substring']))
                end
              end
            end
            @report_templates = @report_templates.compact.uniq.sort_by { |x| x.downcase }
            
        end
        
        if (params[:id] == 'revisions')
            template = 'show_revisions'
        elsif (params[:id] == 'issues')
            template = 'show_issues'
        end
        respond_to do |format|
            format.html { render template }
            format.csv  { (@issues && @issues.size > 0) ? send_data(issues_to_csv(@issues), :type => 'text/csv; header=present', :filename => 'issues.csv') : render_404 }
        end
    end
  
    def show
        @issues = @version.fixed_issues.visible.
        includes(:status, :tracker, :priority, :project).
        reorder("#{Tracker.table_name}.position, #{Issue.table_name}.id").
        all
        
        respond_to do |format|
            format.html { render 'show_version' }
            format.csv  { send_data(issues_to_csv(@issues), :type => 'text/csv; header=present', :filename => 'issues.csv') }
        end
    end

end
