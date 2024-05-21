
def to_boolean(string)
  case string
  when true, /\A(true|t|yes|y|1)\z/i
    true
  when false, nil, '', /\A(false|f|no|n|0)\z/i
    false
  else
    raise ArgumentError, "invalid value for Boolean: \"#{string}\""
  end
end


#TODO: move to another page (arch?)
def get_related_event_types(category, id, quantity)
  all_events = Catalog.create_keventer_json

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
