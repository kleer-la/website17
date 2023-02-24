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

#TODO: move to another page (arch?)
def get_related_event_types(category, id, quantity)
  all_events = KeventerReader.instance.catalog_events()

  all_events.select{|e| e.event_type.categories.any?{|c| c == category}}
            .select{|e| e.event_type.id != id}
            .uniq{ |e| e.event_type.id}
            .first(quantity)
end

def get_related_articles(category, id, quantity)
  all_articles = Article.create_list_keventer(true)

  all_articles.select{|e| e.category_name == category}
            .select{|e| e.id != id}
            .uniq{ |e| e.id}
            .first(quantity)
end
