# encoding: utf-8

module BuildVersionsHelper

  def csv_value(value)
    case value.class.name
    when 'Time'
      format_time(value)
    when 'Date'
      format_date(value)
    when 'Float'
      sprintf("%.2f", value).gsub('.', l(:general_csv_decimal_separator))
    when 'TrueClass'
      l(:general_text_Yes)
    when 'FalseClass'
      l(:general_text_No)
    else
      value.to_s
    end
  end

  def issues_to_csv(items)
    encoding = l(:general_csv_encoding)
	
	columns = [
		{:caption => '#', :field => "item.id"},
		{:caption => 'Проект', :field => "item.project.name"},
        {:caption => 'Трекер', :field => "item.tracker.name"},
        {:caption => 'Тема', :field => "item.subject"},
        {:caption => 'Объекты БД', :field => "format_issue_hashes(item.get_dbobjects)"},
        {:caption => 'Данные БД', :field => "format_issue_hashes(item.get_dbdata)"},
        {:caption => 'Ссылка на задачу', :field => "issue_url(item)"},
	]
    export = FCSV.generate(:col_sep => l(:general_csv_separator), :force_quotes => true) do |csv|
      # csv header fields
      csv << columns.collect {|c| Redmine::CodesetUtil.from_utf8(c[:caption].to_s, encoding) }
      # csv lines
      items.each do |item|
        csv << columns.collect {|c| Redmine::CodesetUtil.from_utf8(csv_value(eval(c[:field])), encoding) }
      end
    end
    export
  end
  
  def format_issue_hashes(hash)
    hash.keys.compact.uniq.sort_by { |x| x.downcase }.join("\r\n").html_safe if hash.is_a?(Hash)
  end
end