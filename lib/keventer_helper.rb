def validated_date_parse(date_xml)
  Date.parse(date_xml.content)
rescue StandardError
  nil
end

def to_boolean(string)
  return true if string == true || string =~ (/(true|t|yes|y|1)$/i)
  return false if string == false || string.nil? || string == '' || string =~ (/(false|f|no|n|0)$/i)

  raise ArgumentError, "invalid value for Boolean: \"#{string}\""
end

def first_content(xml, element_name)
  element = xml.find_first(element_name)
  if element.nil?
    ''
  else
    element.content
  end
end

def first_content_f(xml, element_name)
  first_content(xml, element_name).to_f
end
