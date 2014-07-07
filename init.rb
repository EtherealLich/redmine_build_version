#!/bin/env ruby
# encoding: utf-8

require 'redmine'
require File.dirname(__FILE__) + '/lib/version_patch.rb'
require File.dirname(__FILE__) + '/lib/versions_controller_patch.rb'
require File.dirname(__FILE__) + '/lib/issue_patch.rb'

Redmine::Plugin.register :redmine_build_version do
  name 'Инструменты для сборки версий'
  author 'Ivan Petukhov'
  description 'Инструменты для помощи в сборке версий'
  version '0.1.0'
  url 'http://swan.perm.ru/'
  author_url 'https://github.com/EtherealLich'
  
  settings :default => {
    'report_template_substring' => "rptdesign", # Маска файла шаблона отчета
    'dbobjects_field_name'  => "Объекты в БД", # Название поля с объектами БД
    'dbdata_field_name'  => "Данные в БД", # Название поля с данными БД
  }

end
